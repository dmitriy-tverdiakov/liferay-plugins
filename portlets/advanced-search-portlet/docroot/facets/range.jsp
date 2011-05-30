<%--
/**
 * Copyright (c) 2000-2011 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/init.jsp" %>

<%
String randomNamespace = PortalUtil.generateRandomKey(request, "search-range.jsp") + StringPool.UNDERLINE;

Facet facet = (Facet)request.getAttribute("search-search.jsp-facet");

String fieldName = facet.getFieldName();
String fieldParam = ParamUtil.getString(request, fieldName);

int frequencyThreshold = 0;
JSONArray rangesJSONArray = null;

JSONObject data = facet.getFacetConfiguration().getData();

if (data.has("frequencyThreshold")) {
	frequencyThreshold = data.getInt("frequencyThreshold");
}

if (data.has("ranges")) {
	rangesJSONArray = data.getJSONArray("ranges");
}

FacetCollector facetCollector = facet.getFacetCollector();
%>

<aui:input name="<%= fieldName %>" type="hidden" value="<%= fieldParam %>" />

<%
String rangeNavigation = _buildRangeNavigation(pageContext, fieldParam, frequencyThreshold, rangesJSONArray, facetCollector);

if (Validator.isNotNull(rangeNavigation)) {
%>

	<aui:field-wrapper cssClass='<%= randomNamespace + "range range" %>' label="" name="<%= fieldName %>">
		<%= rangeNavigation %>
	</aui:field-wrapper>

<%
}
else {
%>

	<div class="portlet-msg-info">
		<liferay-ui:message key="there-are-no-matching-ranges" />
	</div>

<%
}
%>

<aui:script position="inline" use="aui-base">
	var container = A.one('.advanced-search-portlet .menu .search-range .<%= randomNamespace %>range');

	if (container) {
		container.delegate(
			'click',
			function(event) {
				var term = event.currentTarget;
				var wasSelfSelected = false;

				var field = document.<portlet:namespace />fm['<portlet:namespace /><%= fieldName %>'];

				var currentTerms = A.all('.advanced-search-portlet .menu .search-range .<%= randomNamespace %>range .entry.current-term a');

				if (currentTerms) {
					currentTerms.each(
						function(item, index, collection) {
							item.ancestor('.entry').removeClass('current-term');

							if (item == term) {
								wasSelfSelected = true;
							}
						}
					);

					field.value = '';
				}

				if (!wasSelfSelected) {
					term.ancestor('.entry').addClass('current-term');
					field.value = term.attr('data-value');
				}

				submitForm(document.<portlet:namespace />fm);
			},
			'.entry a'
		);
	}
</aui:script>

<%!
private String _buildRangeNavigation(PageContext pageContext, String selectedTerm, long frequencyThreshold, JSONArray rangesJSONArray, FacetCollector facetCollector) throws Exception {
	List<TermCollector> termCollectors = facetCollector.getTermCollectors();

	if (termCollectors.isEmpty()) {
		return null;
	}

	StringBundler sb = new StringBundler();

	sb.append("<ul class=\"range\">");

	for (int i = 0; i < rangesJSONArray.length(); i++) {
		JSONObject rangeJSONObject = rangesJSONArray.getJSONObject(i);

		String label = rangeJSONObject.getString("label");
		String range = rangeJSONObject.getString("range");

		TermCollector termCollector = facetCollector.getTermCollector(range);

		int frequency = 0;

		if (termCollector != null) {
			frequency = termCollector.getFrequency();
		}

		if (frequency < frequencyThreshold) {
			continue;
		}

		sb.append("<li class=\"entry");

		if (range.equals(selectedTerm)) {
			sb.append(" current-term");
		}

		sb.append("\"><a href=\"#\" data-value=\"");
		sb.append(HtmlUtil.escapeAttribute(range));
		sb.append("\">");
		sb.append(LanguageUtil.get(pageContext, label));
		sb.append("</a> <span class=\"frequency\">(");
		sb.append(frequency);
		sb.append(")</span></li>");
	}

	sb.append("</ul>");

	return sb.toString();
}
%>