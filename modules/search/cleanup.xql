(:~
    Module to clean up a MODS record. Removes empty elements, empty attributes and elements without required subelements.
:)

module namespace clean="http:/exist-db.org/xquery/mods/cleanup";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace functx = "http://www.functx.com";

(: Removes empty attributes. Attributes are often left empty by the editor. :)
declare function clean:remove-empty-attributes($element as element()) as element() {
element { node-name($element)}
{ $element/@*[string-length(.) ne 0],
for $child in $element/node( )
return 
    if ($child instance of element())
    then clean:remove-empty-attributes($child)
    else $child }
};

(: Removes an element if it is empty or contains whitespace only. A relatedItem should be allowed to be empty if it has an @xlink:href. :)
(: Derived from functx:remove-elements-deep. :)
(: Contains functx:all-whitespace. :)
declare function clean:remove-empty-elements($nodes as node()*)  as node()* {
   for $node in $nodes
   return
     if ($node instance of element())
     then if ((normalize-space($node) = '') and (not($node/@xlink:href)))
          then ()
          else element { node-name($node)}
                { $node/@*,
                  clean:remove-empty-elements($node/node())}
     else if ($node instance of document-node())
     then clean:remove-empty-elements($node/node())
     else $node
 } ;

(: The function called in session.xql which passes search results to retrieve-mods.xql after cleaning them. :)
declare function clean:cleanup($node as node()) {
    (:let $result := clean:remove-empty-attributes($node)
    return:)
        let $result := clean:remove-empty-elements($node)
        return
            $result
            };