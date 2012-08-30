xquery version "1.0";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace request="http://exist-db.org/xquery/request";

declare variable $exist:root external;
declare variable $exist:prefix external;
declare variable $exist:controller external;
declare variable $exist:path external;
declare variable $exist:resource external;

if ($exist:path eq '/') then
    let $msg := 'index'
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="/index.xhtml">
            </forward>
        </dispatch>

else
if (starts-with($exist:path, '/edit/')) then
    let $item := substring-after($exist:path, 'edit/')
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="/xq/xform-runner.xquery">
             <add-parameter name="fid" value="{$item}"/>
            </forward>
        </dispatch>
        
 else
 if (starts-with($exist:path, '/create')) then
 let $item := 'blank_template.xml'
 return
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="/xq/xform-runner.xquery">
             <add-parameter name="fid" value="{$item}"/>
            </forward>
   </dispatch>
   
   (: Let everything else pass through :)
else
    <ignore xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </ignore>
