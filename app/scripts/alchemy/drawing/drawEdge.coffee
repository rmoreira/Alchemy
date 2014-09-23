# Alchemy.js is a graph drawing application for the web.
# Copyright (C) 2014  GraphAlchemist, Inc.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


alchemy.drawing.DrawEdge =
    createLink: (edge) =>
        conf = alchemy.conf
        curved = conf.curvedEdges
        directed = conf.directedEdges
        interactions = alchemy.interactions
        utils = alchemy.drawing.EdgeUtils

        if curved
            edge.append 'path'
                .attr 'class', 'edge-line'
                .attr 'id', (d) -> "path-#{d.id}"
                .each (d) -> d3.select(@).style utils.edgeStyle d
            edge.filter (d) -> d.caption?
                .append 'text'
            edge.append 'path'
                .attr 'class', 'edge-handler'
                .style 'stroke-width', "#{conf.edgeOverlayWidth}"
        else
            edge.append 'line'
                .attr 'class', 'edge-line'
                .attr 'shape-rendering', 'optimizeSpeed'
                .each (d) -> d3.select(@).style utils.edgeStyle d
            edge.filter (d) -> d.caption?
                .append 'text'
            edge.append 'rect'
                .attr 'class', 'edge-handler'

    styleLink: (edge) =>
        conf = alchemy.conf
        curved = conf.curvedEdges
        directed = conf.directedEdges
        utils = alchemy.drawing.EdgeUtils

        if curved
            edge.selectAll 'path'
                 .attr 'd', (d) ->
                    angle = utils.edgeAngle d

                    sideOfY = if Math.abs(angle) > 90 then -1 else 1
                    sideOfX = do (angle) ->
                        if angle != 0
                            return if angle < 0 then -1 else 1
                        0

                    startLine = utils.startLine d
                    endLine = utils.endLine d
                    sourceX = startLine.x
                    sourceY = startLine.y
                    targetX = endLine.x
                    targetY = endLine.y

                    dx = targetX - sourceX
                    dy = targetY - sourceY
                    
                    hyp = Math.sqrt dx * dx + dy * dy

                    offsetX = (dx * alchemy.conf.nodeRadius + 2) / hyp
                    offsetY = (dy * alchemy.conf.nodeRadius + 2) / hyp

                    arrowX = (-sideOfX * ( conf.edgeArrowSize )) + offsetX
                    arrowY = ( sideOfY * ( conf.edgeArrowSize )) + offsetY

                    #M #{startLine.x},    #{startLine.y}     A #{hyp}, #{hyp} #{captionAngle(d)}    0, 1 #{endLine.x},        #{endLine.y}"
                    "M #{sourceX-offsetX},#{sourceY-offsetY} A #{hyp}, #{hyp} #{utils.edgeAngle(d)} 0, 1 #{targetX - arrowX}, #{targetY - arrowY}"
           
            edge.select 'path.edge-line'
                .style (d) -> utils.edgeStyle(d)
    
        else
            edge.select '.edge-line'
                .each (d) ->
                    startLine = utils.startLine d
                    endLine = utils.endLine d
                    d3.select(@).attr
                        'x1': startLine.x
                        'y1': startLine.y
                        'x2': endLine.x
                        'y2': endLine.y
                      .style utils.edgeStyle d
            edge.select '.edge-handler'
                .attr 'x', 0
                .attr 'y', -conf.edgeOverlayWidth/2
                .attr 'height', conf.edgeOverlayWidth
                .attr 'width', (d) -> utils.edgeLength(d)
                .attr 'transform', (d) -> "translate(#{d.source.x}, #{d.source.y}) rotate(#{utils.edgeAngle(d)})"

        if @directed
            edge.select '.edge-line'
                .attr 'marker-end', 'url(#arrow)'

    classEdge: (edge) =>
        edge.classed 'active', true

    styleText: (edge) =>
        conf = alchemy.conf
        curved = conf.curvedEdges
        directed = conf.directedEdges
        utils = alchemy.drawing.EdgeUtils

        if curved
            edge.select 'text'
                .attr 'dx', (d) -> utils.middlePath(d).x
                .attr 'dy', (d) -> utils.middlePath(d).y + 20
                .attr 'transform', (d) -> "rotate(#{utils.captionAngle(d)} #{utils.middlePath(d).x} #{utils.middlePath(d).y})"
                .text (d) -> d.caption
        else
            edge.select 'text'
                .attr 'dx', (d) -> utils.middleLine(d).x
                .attr 'dy', (d) -> utils.middleLine(d).y - 5
                .attr 'transform', (d) -> "rotate(#{utils.captionAngle(d)} #{utils.middleLine(d).x} #{utils.middleLine(d).y})"
                .text (d) -> d.caption

    setInteractions: (edge) =>
        interactions = alchemy.interactions
        editorEnabled = alchemy.getState("interactions") is "editor"
        if editorEnabled
            editorInteractions = new alchemy.editor.Interactions
            edge.select '.edge-handler'
                .on 'click', editorInteractions.edgeClick
        else
            edge.select '.edge-handler'
                .on 'click', interactions.edgeClick
                .on 'mouseover', (d)-> interactions.edgeMouseOver(d)
                .on 'mouseout', (d)-> interactions.edgeMouseOut(d)