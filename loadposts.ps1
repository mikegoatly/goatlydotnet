$pages = @(
    "2006/7/20/Easy-way-to-enter-GUIDs-for-WiX-scripts.aspx",
    "2006/7/13/Configuring-ADAM-to-use-SSL.aspx",
    "2007/8/6/Determining-Framework-SDK-Path.aspx",
    "2008/12/8/Creating-MSBuild-XSD-schemas-for-your-custom-tasks.aspx",
    "2008/1/23/Collapsing-Visual-Studio-Solution-Explorer-to-Project-Definitions.aspx",
    "2008/1/11/Good-Uses-for-SQL-Server-2005-Common-Table-Expressions-(Part-1).aspx",
    "2008/1/10/Good-Uses-for-SQL-Server-2005-Common-Table-Expressions-(Part-0).aspx",
    "2009/12/8/Using-a-recursive-CTE-to-read-the-root-parent-id-of-a-hierarchical-table.aspx",
    "2009/3/9/How-to-determine-the-version-of-IIS.aspx",
    "2010/12/24/Advanced-querying-with-LIFTI.aspx",
    "2010/12/23/401-Unauthorized-when-Acquiring-an-Access-Token-Windows-Live-SDK.aspx",
    "2010/12/7/LIFTI-and-Porter-stemming.aspx",
    "2010/11/19/Using-T4-to-generate-content-at-runtime.aspx",
    "2010/11/18/LIFTI-Searching-Pascal-cased-words.aspx",
    "2010/6/30/Errors-using-a-custom-RIA-authentication-service-(and-how-to-resolve-them).aspx",
    "2010/1/29/Creating-a-lightweight-in-memory-full-text-indexer.aspx",
    "2011/7/1/Tutorial-Using-LIFTI-in-an-MVC-3-web-application.aspx",
    "2011/6/27/Entity-Framework-Code-First-The-path-is-not-valid-Check-the-directory-for-the-database.aspx",
    "2011/6/10/LIFTI-XmlWordSplitter.aspx",
    "2011/6/8/Changes-to-the-LIFTI-API.aspx",
    "2011/4/25/Debugging-The-agent-process-was-stopped-while-the-test-was-running.aspx",
    "2011/4/12/Using-Windows-Live-Mesh-to-synchronize-your-draft-blog-posts.aspx",
    "2011/4/8/Describing-the-LIFTI-persistence-file-format.aspx",
    "2011/4/4/Persisting-GetHashCode-values-is-a-staggeringly-bad-thing-to-do,-and-you-should-know-better.aspx",
    "2011/3/29/Implementing-a-persisted-file-store-for-LIFTI.aspx",
    "2011/3/21/Problems-programatically-creating-AppPool.aspx",
    "2011/3/18/NotSupportedException-when-calling-EndGetResponse-in-Silverlight.aspx",
    "2011/2/2/Debugging-bad-request-errors-Windows-Live-SDK.aspx",
    "2011/1/31/Building-a-debugger-visualizer-for-generic-types.aspx",
    "2011/1/25/Performance-tuning-using-Visual-Studio-2010.aspx",
    "2011/1/16/Writing-multi-threaded-unit-tests.aspx",
    "2011/1/11/Implementing-thread-safety-in-LIFTI.aspx",
    "2011/1/5/LIFTI-Changes-ahoy.aspx",
    "using-azure-mobile-services-from-windows-phone-7-apps",
    "using-winrttriggers-within-data-templates",
    "using-livedatascript",
    "conditional-trigger-actions-with-winrttriggers",
    "triggers-in-winrt-xaml",
    "equazor",
    "new-host-new-look",
    "2012/5/29/Export-all-tables-in-an-Access-database-to-CSV.aspx",
    "2012/5/22/Why-have-my-visual-state-changes-stopped-working.aspx",
    "2012/1/25/Hooking-into-session-start-events-in-an-HTTP-module.aspx",
    "2012/1/20/Article-on-using-SqlBulkCopy-with-POCOs.aspx",
    "2012/1/15/DynaCache-just-like-page-output-caching,-but-for-classes.aspx",
    "customizing-table-names-for-identitydbcontextwithcustomuser-data-contexts",
    "persistedfulltextindexes-with-non-primitive-types",
    "using-dynacache-with-unity",
    "storyboardcompletedtrigger-and-setpropertyaction",
    "aliens-vs-finger",
    "adding-application-insights-to-an-existing-windows-store-project-using-visual-studio-2013-update-3",
    "fixing-nuget-errors-after-removing-microsoft-bcl-build",
    "using-dynacache-with-simpleinjector"
)

$Urls = @($pages | ForEach-Object { @( "-u", "http://goatly.net/$_") })
$Html2mdArgs = @(
    "-o", 
    ".\content\post\", 
    "-i", 
    ".\static\images\post\",
    "--image-path-prefix", 
    "/images/post/"
    "--it",
    "//article[@class='blog-post content-item']",
    "--et",
    "header,//h2[@class='comment-count'],//ul[@class='comments'],//div[@id='comments']",
    "--code-language-class-map",
    "xml:xml,sh_csharp:csharp",
    "--front-matter-data",
    "title://article/header/h1",
    "--front-matter-data",
    "date://div[@class='metadata']/div[@class='published']:Date",
    "--front-matter-data",
    "author:{{'Mike Goatly'}}",
    "--front-matter-data-list",
    "tags://p[@class='tags']/a",
    "--logging",
    "Debug"
)

$Html2mdArgs = $Html2mdArgs + $Urls

& 'html2md.exe' $Html2mdArgs

