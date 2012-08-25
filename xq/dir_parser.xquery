xquery version "1.0";
declare namespace httpclient="http://exist-db.org/xquery/httpclient";
declare namespace request="http://exist-db.org/xquery/request";

let $param := request:get-parameter("coll-id", 0)
let $base_url := 'http://sga.mith.org/images/derivatives/'
let $dir_url := concat($base_url, $param)

let $data := httpclient:get(xs:anyURI($dir_url), true(), <Headers/>)
return if ($data[@statusCode != '200'])
    then <error http-status-code="{$data/@statusCode}">Loading collection items failed.</error>
    else
    <links>
        {
        for $item in $data//td/a
            return $item
        }
    </links>
