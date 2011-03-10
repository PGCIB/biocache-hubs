<%-- 
    Document   : list
    Created on : Feb 2, 2011, 10:54:57 AM
    Author     : "Nick dos Remedios <Nick.dosRemedios@csiro.au>"
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="/common/taglibs.jsp" %>
<c:set var="biocacheServiceUrl" scope="request"><ala:propertyLoader bundle="hubs" property="biocacheRestService.biocacheUriPrefix"/></c:set>
<c:set var="queryDisplay">
    <c:choose><c:when test="${not empty searchResults.queryTitle}">${searchResults.queryTitle}</c:when><c:otherwise>${searchRequestParams.displayString}</c:otherwise></c:choose>
</c:set>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Occurrence Search Results | OZCAM</title>
        <script type="text/javascript">
            contextPath = "${pageContext.request.contextPath}";
            searchString = "${searchResults.urlParameters}"; 
        </script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/getQueryParam.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery.oneshowhide.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery-ui-1.8.10.core.slider.min.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/search.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/envlayers.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/config.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/map.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/wms.js"></script>
        <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
        <script type="text/javascript">
            Config.setupUrls("${biocacheServiceUrl}");
        </script>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/search.css" type="text/css" media="screen" />
        <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/button.css" type="text/css" media="screen" />
        <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/map.css" type="text/css" media="screen" />
        <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/redmond/jquery.ui.redmond.css" type="text/css" media="screen" />
    </head>
    <body>

        <input type="hidden" id="userId" value="${userId}">
        <div id="headingBar">
            <h1>Occurrence Records<a name="resultsTop">&nbsp;</a></h1>
            <div id="searchBox">
                <form action="${pageContext.request.contextPath}/occurrences/search" id="solrSearchForm">
                    <input type="submit" id="searchSubmit" value="Search"/>
                    <input type="text" id="solrQuery" name="q" value="${param.q}">
                    <input type="hidden" id="lsid" value=""/>
                </form>
            </div>
        </div>
        <div style="clear: both"/>
        <c:if test="${searchResults.totalRecords > 0}">
            <jsp:include page="facetsDiv.jsp"/>
        </c:if>
        <div id="content">
            <c:if test="${searchResults.totalRecords == 0}">
                <p>No records found for <b>${queryDisplay}</b></p>
            </c:if>
            <c:if test="${searchResults.totalRecords > 0}">
                <a name="map" class="jumpTo">&nbsp;</a><a name="list" class="jumpTo">&nbsp;</a>
                <div>
                    <div id="listMapToggle" class="row" >
                        <button class="rounded" id="listMapButton">
                            <span id="listMapLink">Map</span>
                        </button>
                    </div>
                    <div id="resultsReturned"><strong><fmt:formatNumber value="${searchResults.totalRecords}" pattern="#,###,###"/></strong> results
                        for <strong>${queryDisplay}</strong>
                        (<a href="#download" title="Download all <fmt:formatNumber value="${searchResults.totalRecords}" pattern="#,###,###"/> records as a tab-delimited file" id="downloadLink">Download all records</a>)
                    </div>
                    <div style="display:none">
                        <jsp:include page="downloadDiv.jsp"/>
                    </div>
                </div>
                <div id="resultsOuter">
                    <div class="solrResults">
                        <div id="dropdowns">
                            <div id="resultsStats">
                                Results per page
                                <select id="per-page" name="per-page">
                                    <c:set var="pageSizeVar">
                                        <c:choose>
                                            <c:when test="${not empty param.pageSize}">${param.pageSize}</c:when>
                                            <c:otherwise>20</c:otherwise>
                                        </c:choose>
                                    </c:set>
                                    <option value="10" <c:if test="${pageSizeVar eq '10'}">selected</c:if>>10</option>
                                    <option value="20" <c:if test="${pageSizeVar eq '20'}">selected</c:if>>20</option>
                                    <option value="50" <c:if test="${pageSizeVar eq '50'}">selected</c:if>>50</option>
                                    <option value="100" <c:if test="${pageSizeVar eq '100'}">selected</c:if>>100</option>
                                </select>
                            </div>
                            <div id="sortWidget">
                                Sort by
                                <select id="sort" name="sort">
                                    <option value="score" <c:if test="${param.sort eq 'score'}">selected</c:if>>best match</option>
                                    <option value="taxon_name" <c:if test="${param.sort eq 'taxon_name'}">selected</c:if>>scientific name</option>
                                    <option value="common_name" <c:if test="${param.sort eq 'common_name'}">selected</c:if>>common name</option>
                                    <!--                            <option value="rank">rank</option>-->
                                    <option value="occurrence_date" <c:if test="${param.sort eq 'occurrence_date'}">selected</c:if>>record date</option>
                                    <option value="record_type" <c:if test="${param.sort eq 'record_type'}">selected</c:if>>record type</option>
                                </select>
                                Sort order
                                <select id="dir" name="dir">
                                    <option value="asc" <c:if test="${param.dir eq 'asc'}">selected</c:if>>normal</option>
                                    <option value="desc" <c:if test="${param.dir eq 'desc'}">selected</c:if>>reverse</option>
                                </select>

                            </div><!--sortWidget-->
                        </div><!--drop downs-->
                        <div id="results">
                            <c:forEach var="occurrence" items="${searchResults.occurrences}">
                                <p class="rowA">Record: <a href="<c:url value="/occurrences/${occurrence.uuid}"/>" class="occurrenceLink" style="font-size: 100%; color: #005A8E;">${occurrence.raw_collectionCode}:${occurrence.raw_catalogNumber}</a> &mdash;
                                    <span style="text-transform: capitalize">${occurrence.taxonRank}</span>: <span class="occurrenceNames"><alatag:formatSciName rankId="6000" name="${occurrence.scientificName}"/></span>
                                    <c:if test="${not empty occurrence.vernacularName}"> | <span class="occurrenceNames">${occurrence.vernacularName}</span></c:if>
                                </p>
                                <p class="rowB">
                                    <c:if test="${not empty occurrence.dataResourceName}"><span style="text-transform: capitalize;"><strong class="resultsLabel">Institution:</strong> ${fn:replace(occurrence.dataResourceName, ' provider for OZCAM', '')}</span></c:if>
                                    <%-- <c:if test="${not empty occurrence.institutionName}"><span style="text-transform: capitalize;"><strong class="resultsLabel">Institution</strong> ${occurrence.institutionName}</span></c:if> --%>
                                    <c:if test="${not empty occurrence.basisOfRecord}"><span style="text-transform: capitalize;"><strong class="resultsLabel">Basis of record:</strong> ${occurrence.basisOfRecord}</span></c:if>
                                    <c:if test="${not empty occurrence.eventDate}"><span style="text-transform: capitalize;"><strong class="resultsLabel">Date:</strong> <fmt:formatDate value="${occurrence.eventDate}" pattern="yyyy-MM-dd"/></span></c:if>
                                    <c:if test="${not empty occurrence.stateProvince}"><span style="text-transform: capitalize;"><strong class="resultsLabel">State:</strong> <fmt:message key="region.${occurrence.stateProvince}"/></span></c:if>
                                </p>
                            </c:forEach>
                        </div><!--close results-->
                        <div id="searchNavBar">
                            <alatag:searchNavigationLinks totalRecords="${searchResults.totalRecords}" startIndex="${searchResults.startIndex}"
                                                          lastPage="${lastPage}" pageSize="${searchResults.pageSize}"/>
                        </div>
                    </div><!--end solrResults-->
                    <div id="mapwrapper">
                        <div>
                            <label for="colourFacets">Colour by:</label>
                            <select name="colourFacets" id="colourFacets">
                                <option value=""> -- Select an option -- </option>
                                <c:forEach var="facetResult" items="${searchResults.facetResults}">
                                    <c:if test="${fn:length(facetResult.fieldResult) > 1 && empty facetMap[facetResult.fieldName]}">
                                        <option value="${facetResult.fieldName}"><fmt:message key="facet.${facetResult.fieldName}"/></option>
                                    </c:if>
                                </c:forEach>
                            </select>

                            <label for="envLyrList">Environmental Layer:</label>
                            <select id="envLyrList">
                                <option value="">None</option>
                            </select>

                            <!-- size slider start -->
                            <div id="slidercontainer">
                                <div id="sizeslider"></div>
                                <label for="sizeslider">Size: </label><span id="sizeslider-val">4</span>
                            </div>
                            <!-- size slider end -->



                        </div>
                        <div id="mapcanvas"></div>
                        <div id="legend" title="Toggle layers/legend display">                            
                            <div class="title">Layers<span>&nabla;</span></div>
                            <div id="layerlist">
                                <!--
                            <div id="envLayers">
                                <div>
                                    <input type="radio" name="envBio11" /> Bio11
                                </div>
                                <div>
                                    <input type="radio" name="envBio12" /> Bio12
                                </div>
                                <div>
                                    <input type="radio" name="envBio34" /> Bio34
                                </div>
                                <div>
                                    <input type="radio" name="envCars2006" /> CARS 2006
                                </div>
                                <div>
                                    <input type="radio" name="envCars2009a" /> CARS 2009a
                                </div>
                            </div>
                                -->
                                <div id="legendContent"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>
        </div>
  </body>
</html>