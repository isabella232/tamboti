xquery version "1.0";

module namespace mods = "http://www.loc.gov/mods/v3";

import module namespace config="http://exist-db.org/mods/config" at "../config.xqm";

declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace xforms="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events";

declare variable $mods:tabs-file := concat($config:edit-app-root, '/tab-data.xml');
declare variable $mods:body-file-collection := concat($config:edit-app-root, '/body');
declare variable $mods:code-table-collection := concat($config:edit-app-root, '/code-tables');


(: Display the tabs in a div using triggers that hide or show sub-tabs and tabs. :)
declare function mods:tabs($tab-id as xs:string, $id as xs:string, $data-collection as xs:string) as node()  {

(: get the show-level param from the URL; if empty, set it to 1. :)
let $type := request:get-parameter("type", '')
(: get the show-level param from the URL; if it is empty, it is because the record has just been initialised; 
if it is a non-basic template, set it to 2 (to show Citationforms/Title Information), 
otherwise set it to 1 (to show Basic Input Forms/Main Publication). :)
let $show-level := xs:integer(request:get-parameter("show-level", 
    if ($type = ('insert-templates','new-instance'))
    then 2
    else 1
    ))


(: get a sequence of tab entries from the tab database :)
let $tabs-data := doc($mods:tabs-file)/tabs/tab

(: get a sequence of all the top tabs :)
let $all-categories := distinct-values($tabs-data/category/text())

(: get top tabs that have at least one visible sub-tab :)
(:
let $visible-categories :=
    if ($show-level = 3) 
    then
        for $category in $all-categories
        let $count-of-visible-subcategories := count($tabs-data[category/text() = $category and show-level = $show-level]) 
            return 
                if ($count-of-visible-subcategories > 0)
                then $category
                else ()
    else 
        if ($show-level = 2) 
        then
            for $category in $all-categories
            let $count-of-visible-subcategories := count($tabs-data[category/text() = $category and show-level = $show-level]) 
                return 
                    if ($count-of-visible-subcategories > 0)
                    then $category
                    else ()
        else 
           for $category in $all-categories
           let $count-of-visible-subcategories :=
               count($tabs-data[category/text() = $category and show-level = $show-level]) 
               return 
                   if ($count-of-visible-subcategories > 0)
                   then $category
                   else ()
:)
return
<div class="tabs">
    <table class="top-tabs" width="100%">
        <tr>
            {
            for $category in $all-categories
            let $category-count := count($tabs-data[category/text() = $category])
            return
            <td style="{if ($tabs-data[category = $category]/show-level = $show-level) then "background:white;border-bottom-color:white;" else "background:#EDEDED"}">
                {attribute{'width'}{100 div $category-count}}
                <xf:trigger appearance="minimal">
                    <xf:label>
                        <div class="label" style="{if ($tabs-data[category = $category]/show-level = $show-level) then "font-weight:bold;color:#3681B3;" else "font-weight:bold;color:darkgray"}">
                    <span class="tab-text">{$category}
                </span>
                    </div>
                    </xf:label>
                    <xf:action ev:event="DOMActivate">
                        <!--When clicking on the top tabs, save the record. -->
                        <xf:send submission="save-submission"/>
                        <!--When clicking on the top tabs, select the first of the bottom tabs. -->
                        <xf:load resource="edit.xq?tab-id={$tabs-data[category = $category][1]/tab-id[1]}&amp;id={$id}&amp;show-level={$tabs-data[category = $category][1]/show-level[1]}&amp;type={$type}&amp;collection={$data-collection}" show="replace"/>
                    </xf:action>
                </xf:trigger>                
            </td>
            }
            </tr>
            </table>
            <table class="bottom-tabs">                    
                <tr>
                {
                for $tab in $tabs-data[show-level = $show-level]
                return
                <td style="{if ($tab-id = $tab/tab-id/text()) then "background:white;border-bottom-color:white;color:#3681B3;" else "background:#EDEDED"}">
                    <xf:trigger appearance="minimal">
                        <xf:label><div class="label" style="{if ($tab-id = $tab/tab-id/text()) then "color:#3681B3;font-weight:bold;" else "color:darkgray;font-weight:bold"}">{$tab/label/text()}</div></xf:label>
                        <xf:action ev:event="DOMActivate">
                            <xf:send submission="save-submission"/>
                            <!--When clicking on the bottom tabs, keep the show-level the same. -->
                            <xf:load resource="edit.xq?tab-id={$tab/tab-id/text()}&amp;id={$id}&amp;show-level={$show-level}&amp;type={$type}&amp;collection={$data-collection}" show="replace"/>
                        </xf:action>
                    </xf:trigger>
                </td>
                }
                </tr>
            </table>
</div>
};