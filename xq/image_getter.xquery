xquery version "1.0";
declare namespace httpclient="http://exist-db.org/xquery/httpclient";
declare namespace request="http://exist-db.org/xquery/request";
(:declare namespace exist = "http://exist.sourceforge.net/NS/exist";:)

(:declare option exist:serialize "method=json media-type=text/javascript";:)

let $collection := request:get-parameter("coll-id", 0)
let $item := request:get-parameter("item", 0)
let $base_url := 'http://sga.mith.org/images/derivatives/'
let $dir_url := concat($base_url, $collection)

let $data := httpclient:get(xs:anyURI($dir_url), true(), <Headers/>)

return
    <links>
        {
        for $link in $data//td/a
            where matches($link, $item) = true()
            return $link
        }
    </links>