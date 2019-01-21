// Copyright 2007-2012 The MathWorks, Inc.

// Class RTW_Hash ------------------------------------------------------------
// Innternal web browser doesn't change window.location.hash if the link points
// to the same page.
// RTW_Hash remembers the hash value when the page is loaded in the first time 
// or a link is clicked.
// removeHiliteByHash cleans the high lighted elements according to the stored 
// hash value
function RTW_Hash(aHash) {
    if (aHash == null) {
        this.fHash = "";
    } else {
        this.fHash = aHash;
    };
    
    this.getHash = function() {
        return this.fHash;
    }

    this.setHash = function(aHash) {
        this.fHash = aHash;
    }
}

RTW_Hash.instance = null;

// Class RTW_TraceInfo --------------------------------------------------------
function RTW_TraceInfo(aFileLinks) {
  this.fFileLinks = aFileLinks;
  this.fLines = new Array();
  this.fNumLines = new Array();
  this.fFileIdxCache = new Array();
  this.fDisablePanel = false;
  this.fCurrFileIdx = 0;
  this.fCurrLineIdx = 0;
  this.fCurrCodeNode = null;
  this.getHtmlFileName = function(aIndex) {
    if (aIndex < this.fFileLinks.length) {
      var href = this.fFileLinks[aIndex].href;
      return href.substring(href.lastIndexOf('/')+1);
    }
  }
  this.getSrcFileName = function(aIndex) {
    var name = this.getHtmlFileName(aIndex);
    if (name)
      name = RTW_TraceInfo.toSrcFileName(name);
    return name;
  }
  this.getNumFileLinks = function() {
    return this.fFileLinks.length;
  }
  this.setFileLinkColor = function(aIndex, aColor) {
    var link = this.fFileLinks[aIndex];
    if (link && link.parentNode && link.parentNode.style)
      link.parentNode.style.backgroundColor = aColor;
  }
  this.highlightFileLink = function(aIndex, aColor) {
    for (var i = 0; i < this.fFileLinks.length; ++i) {
      this.setFileLinkColor(i, i == aIndex ? aColor : "");
    }
  }
  this.highlightCurrFileLink = function(aColor) {
    this.highlightFileLink(this.fCurrFileIdx);
  }
  this.highlightLines = function(aCodeNode,aColor) {
    this.fCurrCodeNode = aCodeNode;
    var lines = this.fLines[this.getHtmlFileName(this.fCurrFileIdx)];
    if (lines && aCodeNode) {
      for (var i = 0; i < lines.length; ++i) {
        var lineObj = aCodeNode.childNodes[lines[i]-1];
        if (lineObj)
          lineObj.style.backgroundColor=aColor;
      }
    }
  }
  this.getFileIdx = function(aFile) {
    if (this.fFileIdxCache[aFile] != null)
      return this.fFileIdxCache[aFile];
    for (var i = 0; i < this.fFileLinks.length; ++i) {
      if (this.getHtmlFileName(i) == aFile) {
        this.fFileIdxCache[aFile] = i;
        return i;
      }
    }
    return null;
  }
  this.getCurrFileIdx = function() { return this.fCurrFileIdx; }
  this.setNumHighlightedLines = function(aFileIdx, aNumLines) {
    this.fNumLines[aFileIdx] = aNumLines;
    var parent = this.fFileLinks[aFileIdx].parentNode;
    if (parent && parent.childNodes && parent.childNodes.length > 1 &&
        parent.lastChild.innerHTML != undefined) {
      if (aNumLines > 0)
        parent.lastChild.innerHTML = "&nbsp;("+aNumLines+")";
      else
        parent.lastChild.innerHTML = " ";
    }
  }
  this.getNumLines = function(aFileIdx) {
    return this.fNumLines[aFileIdx] != null ? this.fNumLines[aFileIdx] : 0;
  }
  this.getNumLinesAll = function() {
      var sum = 0;
      var len = this.fNumLines.length;
      for (var i = 0; i < len; ++i) {
          sum += this.getNumLines(i);
      }
      return sum;
  }
  this.getPrevButton = function() {
      var aFrame = rtwTocFrame();
      if (typeof aFrame !== "undefined" && aFrame !== null)
          return rtwTocFrame().document.getElementById("rtwIdButtonPrev");
      else
          return document.getElementById("rtwIdButtonPrev");
  }
  this.getNextButton = function() {
      var aFrame = rtwTocFrame();
      if (typeof aFrame !== "undefined" && aFrame !== null)
          return rtwTocFrame().document.getElementById("rtwIdButtonNext");
      else
          return document.getElementById("rtwIdButtonNext");
  }
  this.getPanel = function() {
      var aFrame = rtwTocFrame();
      if (typeof aFrame !== "undefined" && aFrame !== null)
          return rtwTocFrame().document.getElementById("rtwIdTracePanel");
      else
          return document.getElementById("rtwIdTracePanel");
  }
  this.removeHighlighting = function() {
    for (var i = 0; i < this.fFileLinks.length; ++i) {
      this.setFileLinkColor(i, "");
      this.setNumHighlightedLines(i, 0);
    }
    // remove highlight and reset current code node
    try {
        if (this.fCurrCodeNode != null)
            this.highlightLines(getCodeNode(),"");
    } catch (e) {};
    this.fCurrCodeNode = null;    
    if (this.getPrevButton()) { this.getPrevButton().disabled = true; }
    if (this.getNextButton()) { this.getNextButton().disabled = true; }
    if (this.getPanel()) { this.getPanel().style.display = "none"; }
    this.fCurrFileIdx = 0;
    this.fCurrLineIdx = 0;
  }
  this.setCurrent = function(aFileIdx, aLineIdx) {
    this.fCurrFileIdx = aFileIdx;
    var numLines = this.getNumLines(aFileIdx);
    if (!numLines || aLineIdx >= numLines)
      this.fCurrLineIdx = -1;
    else
      this.fCurrLineIdx = aLineIdx;
    var allNumLines = this.getNumLinesAll();
    if (this.getPrevButton()) {
      this.getPrevButton().disabled = (allNumLines <= 1 || !this.hasPrev());
    }
    if (this.getNextButton()) {
      this.getNextButton().disabled = (allNumLines <= 1 || !this.hasNext());
    }
    if (this.getPanel() && !this.fDisablePanel) {
      this.getPanel().style.display = 'block';
    }
  }
  this.setDisablePanel = function(aDisable) {
    this.fDisablePanel = aDisable;
  }
  this.getPrevFileIdx = function() {
    if (this.fCurrLineIdx > 0)
      return this.fCurrFileIdx;
    for (var i = this.fCurrFileIdx - 1; i >= 0; --i)
      if (this.fNumLines[i] > 0)
        return i;
    return null;
  }
  this.hasPrev = function() {
    return this.getPrevFileIdx() != null;
  }
  this.goPrev = function() {
    var fileIdx = this.getPrevFileIdx();
    if (fileIdx == null)
      return;
    if (fileIdx == this.fCurrFileIdx)
      --this.fCurrLineIdx;
    else {
      this.fCurrFileIdx = fileIdx;
      this.fCurrLineIdx = this.getNumLines(fileIdx) - 1;
    }
    if (this.getPrevButton())
      this.getPrevButton().disabled = !this.hasPrev();
    if (this.getNextButton())
      this.getNextButton().disabled = !this.hasNext();
  }
  this.getNextFileIdx = function() {
    if (this.fCurrLineIdx < this.getNumLines(this.fCurrFileIdx) - 1 && this.getNumLines(this.fCurrFileIdx) > 0)
      return this.fCurrFileIdx;
    for (var i = this.fCurrFileIdx + 1; i < this.getNumFileLinks(); ++i)
      if (this.fNumLines[i] > 0)
        return i;
    return null;
  }
  this.hasNext = function() {
    return this.getNextFileIdx() != null;
  }
  this.goNext = function() {
    var fileIdx = this.getNextFileIdx();
    if (fileIdx == null)
      return;
    if (fileIdx == this.fCurrFileIdx)
      ++this.fCurrLineIdx;
    else {
      this.fCurrFileIdx = fileIdx;
      this.fCurrLineIdx = 0;
    }
    if (this.getNextButton())
      this.getNextButton().disabled = !this.hasNext();
    if (this.getPrevButton())
      this.getPrevButton().disabled = !this.hasPrev();
  }
  this.setLines = function(aFile, aLines) {
    this.fLines[aFile] = aLines;
    var index = this.getFileIdx(aFile);
    if (index != null)
      this.setNumHighlightedLines(index,aLines.length);
  }
  this.getLines = function(aFile) {
    return this.fLines[aFile];
  }
  this.getHRef = function(aFileIdx, aLineIdx, offset) {
    if (offset == undefined)
      offset = 10;
    var file = this.getHtmlFileName(aFileIdx);
    var lines = this.fLines[file];
    if (lines) {
      var line = lines[aLineIdx];
      if (offset > 0)
        line = (line > offset ? line - offset : 1);
      file = file+"#"+line;
    }
    return file;
  }
  this.getCurrentHRef = function(offset) {
    return this.getHRef(this.fCurrFileIdx, this.fCurrLineIdx,offset);
  }
  this.setInitLocation = function(aFile, aLine) {
    var fileIdx = this.getFileIdx(aFile);
    var lineIdx = null;
    if (fileIdx != null) {
      var lines = this.getLines(aFile);
      for (var i = 0; i < lines.length; ++i) {
        if (lines[i] == aLine) {
          lineIdx = i;
          break;
        } 
      }
    }
    if (fileIdx == null || lineIdx == null)
      this.setCurrent(0,-1);
    else
      this.setCurrent(fileIdx,lineIdx);
  }
}

// Static methods in RTW_TraceInfo

RTW_TraceInfo.getFileLinks = function(docObj) {
  var links;
  if (docObj && docObj.getElementsByName)
    links = docObj.getElementsByName("rtwIdGenFileLinks");
  return links ? links : new Array();
}

RTW_TraceInfo.toSrcFileName = function(aHtmlFileName) {
  aHtmlFileName = aHtmlFileName.replace(/_c.html$/,".c");
  aHtmlFileName = aHtmlFileName.replace(/_h.html$/,".h");
  aHtmlFileName = aHtmlFileName.replace(/_cpp.html$/,".cpp");
  aHtmlFileName = aHtmlFileName.replace(/_hpp.html$/,".hpp");
  aHtmlFileName = aHtmlFileName.replace(/_cc.html$/,".hpp");
  return aHtmlFileName;
}

RTW_TraceInfo.instance = null;

// Class RTW_TraceArgs --------------------------------------------------------
// file.c:10,20,30&file.h:10,20,30[&color=value] or 
// sid=model:1[&color=value]
RTW_TraceArgs = function(aHash) {
  this.fColor = null;
  this.fFontSize = null;
  this.fInitFile = null;
  this.fInitLine = null;
  this.fSID = null;
  this.fFiles = new Array();
  this.fLines = new Array();
  this.fMessage = null;
  this.fBlock = null;  
  this.fUseExternalBrowser = true;
  this.fModel2CodeSrc = null;

  this.hasSid = function() {
      return !(this.fSID == null);
  }
  this.parseCommand = function(aHash) {
      var args = new Array();
      args = aHash.split('&');
      for (var i = 0; i < args.length; ++i) {
          var arg = args[i];
          sep = arg.indexOf('=');
          if (sep != -1) {
              var cmd = arg.substring(0,sep);
              var opt = arg.substring(sep+1);
              switch (cmd.toLowerCase()) {
                case "color":
                  this.fColor = opt;
                  break;
                case "fontsize":
                  this.fFontSize = opt;
                  break;
                case "initfile":
                  this.fInitFile = RTW_TraceArgs.toHtmlFileName(opt);
                  break;
                case "initline":
                  this.fInitLine = opt;
                  break;
                case "msg":
                  this.fMessage = opt;
                  break;
                case "block":
                  this.fBlock = unescape(opt);
                  break;
                case "sid":
                  this.fSID = opt;
                  // convert sid to code location
                  break;
                case "model2code_src":
                  // model2code_src from model or webview
                  this.fModel2CodeSrc = opt;
                  break;
                case "useexternalbrowser":
                  this.fUseExternalBrowser = (opt=="true");
                  break;
              }
          }
      }    
  }
  this.parseUrlHash = function(aHash) {
      if (aHash) {
          args = aHash.split('&');
          for (var i = 0; i < args.length; ++i) {
              var arg = args[i];
              sep = arg.indexOf(':');
              if (sep != -1) {
                  var fileLines = arg.split(':');
                  var htmlFileName = RTW_TraceArgs.toHtmlFileName(fileLines[0]);
                  this.fFiles.push(htmlFileName);
                  if (fileLines[1])
                      this.fLines.push(fileLines[1].split(','));
              }
          }
          if (this.fInitFile == null && this.fFiles.length > 0) {
              this.fInitFile = this.fFiles[0];
              this.fInitLine = (this.fLines[0] == null ? -1 : this.fLines[0][0]);
          }
      }
  }
  
  this.getColor = function() { return this.fColor; }
  this.getFontSize = function() { return this.fFontSize; }
  this.getInitFile = function() { return this.fInitFile; }
  this.getInitLine = function() { return this.fInitLine; }
  this.getNumFiles = function() { return this.fFiles.length; }
  this.getSID = function() { return this.fSID; }
  this.getFile = function(aIdx) { return this.fFiles[aIdx]; }
  this.getLines = function(aIdx) { return this.fLines[aIdx]; } 
  this.getUseExternalBrowser = function() { return this.fUseExternalBrowser; } 
  this.getModel2CodeSrc = function() { return this.fModel2CodeSrc; }
  this.setUseExternalBrowser = function(val) { this.fUseExternalBrowser = val; } 
  this.setModel2CodeSrc = function(val) { this.fModel2CodeSrc = val; }

  // constructor
  this.parseCommand(aHash);
}

// Static methods in RTW_TraceArgs

RTW_TraceArgs.toHtmlFileName = function(aFile) {
  f = aFile;
  aFile = f.substring(0,f.lastIndexOf('.')) + '_' + f.substring(f.lastIndexOf('.')+1) + ".html";
  return aFile;
}

RTW_TraceArgs.instance = null;

RTW_MessageWindow = function(aWindow, aParagraph) {
  this.fWindow    = aWindow;
  this.fParagraph = aParagraph;
  
  this.print = function(msg) {
    this.fParagraph.innerHTML = msg;
    if (msg)
      this.fWindow.style.display = "block";
    else
      this.fWindow.style.display = "none";
  }
  this.clear = function() {
    this.print("");
  }
}

// RTW_MessageWindow factory
RTW_MessageWindowFactory = function(aDocObj) {
  this.fDocObj = aDocObj;
  this.fInstance = null;

  this.getInstance = function() {
    if (this.fInstance)
      return this.fInstance;
    if (!this.fDocObj)
      return;
      
    var table     = this.fDocObj.getElementById("rtwIdMsgWindow");
    var paragraph = this.fDocObj.getElementById("rtwIdMsg");
    var button    = this.fDocObj.getElementById("rtwIdButtonMsg");

    if (!table || !paragraph || !button)
      return null;

    obj = new RTW_MessageWindow(table,paragraph);
    button.onclick = function() { obj.clear(); }
    this.fInstance = obj;
    return this.fInstance;
  }
}

RTW_MessageWindowFactory.instance = null;
RTW_MessageWindow.factory = function(aDocObj) {
  if (!RTW_MessageWindowFactory.instance)
    RTW_MessageWindowFactory.instance = new RTW_MessageWindowFactory(aDocObj);
  return RTW_MessageWindowFactory.instance.getInstance();
}

// Callbacks and helper functions ---------------------------------------------

// Helper functions
function getCodeNode() {
    return rtwSrcFrame().document.getElementById("RTWcode");
}

function rtwSrcFrame() {
  return top.rtwreport_document_frame;
}
function rtwTocFrame() {
  return top.rtwreport_contents_frame;
}

function rtwGetFileName(url) {
  var slashIdx = url.lastIndexOf('/');
  var hashIdx  = url.indexOf('#', slashIdx);
  if (hashIdx == -1)
    return url.substring(slashIdx+1)
  else
    return url.substring(slashIdx+1,hashIdx);
}

// Help function to expand the file group
function expandFileGroup(docObj, tagID) {
  if (docObj.getElementById) {
    var obj_table = docObj.getElementById(tagID);
    var o;
    while (obj_table.nodeName != "TABLE") {
      if (obj_table.parentNode) {
        obj_table = obj_table.parentNode;
      } else {
        return;
      }
    }
    if (obj_table.style.display == "none") {
      var category_table = obj_table.parentNode;
      while (category_table.nodeName != "TABLE") {
        if (category_table.parentNode) {
          category_table = category_table.parentNode;
        } else {
          return;
        }        
      }
      var o = category_table.id + "_button";
      o = docObj.getElementById(o);
      if (o && top.rtwreport_contents_frame.rtwFileListShrink) {
        top.rtwreport_contents_frame.rtwFileListShrink(o, category_table.id, 0);
      }
    }
  }
}
// Help function to set the background color based on Element's Id in a document
// object
function setBGColorByElementId(docObj, tagID, bgColor) {
    var status = false;
    if (bgColor == "") {
      bgColor = "TRANSPARENT";
    }
    
    if (docObj.getElementById) {
        var obj2Hilite = docObj.getElementById(tagID);
        if (obj2Hilite && obj2Hilite.parentNode) {
            obj2Hilite.parentNode.style.backgroundColor = bgColor;
            status = true;
        }
    }
    return status;
}

// Help function to set the background color based on Element's name in a document
// object
function setBGColorByElementsName(docObj, tagName, bgColor) {
  if (bgColor == "") {
    bgColor = "TRANSPARENT";
  }  
  if (docObj.getElementsByName) {
    var objs2Hilite = docObj.getElementsByName(tagName);
    for (var objIndex = 0; objIndex < objs2Hilite.length; ++objIndex) {     
        if (objs2Hilite[objIndex].parentNode)
            objs2Hilite[objIndex].parentNode.style.backgroundColor = bgColor;
    }
  }
}

// Help function to highlight lines in source file based on Element's name
// Note: Name of docHiliteByElementsName would be better
function hiliteByElementsName(winObj, tagName) {
    var hiliteColor = "#aaffff";
    if (winObj.document)
        setBGColorByElementsName(winObj.document, tagName, hiliteColor);
}

// Help function to remove the highlight of lines in source file based on Element's name
function removeHiliteByElementsName(winObj, tagName) {
    if (winObj.document)
        setBGColorByElementsName(winObj.document, tagName, "");
}

// Help function to set the background color based on the URL's hash
function setBGColorByHash(docObj, bgColor) {    
    if (docObj.location) {
        var tagName = docObj.location.hash;
        // Use the stored hash value if it exists because the location.hash
        // may be wrong in internal web browser
        if (RTW_Hash.instance)
            tagName = RTW_Hash.instance.getHash();
        if (tagName != null)
            tagName = tagName.substring(1);
        
        var codeNode = docObj.getElementById("RTWcode");
        if (tagName != null && tagName != "") {        
            if (!isNaN(tagName))
                tagName = Number(tagName) + 10;            
            setBGColorByElementsName(docObj, tagName, bgColor);
        }
   }
}

// Highlight the lines in document frame based on the URL's hash
function hiliteByHash(docObj) {       
    var hiliteColor = "#aaffff";  
    setBGColorByHash(docObj, hiliteColor);
}

// Remove highlight of lines in document frame based on the URL's hash
function removeHiliteByHash(winObj) {
    if (winObj.document)
        setBGColorByHash(winObj.document, "");
}

// Highlight the filename Element in TOC frame based on the URL's filename
function hiliteByFileName(aHref) {       
    var status = false;;
    if (!top.rtwreport_contents_frame)
        return status;
    var hiliteColor = "#ffff99";  
    var fileName = rtwGetFileName(aHref);    
    if (top.rtwreport_contents_frame.document) {
        removeHiliteFileList(top.rtwreport_contents_frame);
        status = setBGColorByElementId(top.rtwreport_contents_frame.document, fileName, hiliteColor);
        if (status)
            expandFileGroup(top.rtwreport_contents_frame.document, fileName);
    }
    return status;
}

// Clear the highlights in the code navigation frame.
function removeHiliteCodeNav(winObj) {    
    removeHiliteTOC(winObj);
    removeHiliteFileList(winObj);
}
// Clear the highlights in TOC frame. TOC links are named TOC_List
function removeHiliteTOC(winObj) {    
    removeHiliteByElementsName(winObj, "TOC_List"); 
}
// Clear the highlights in Generated File List. 
// The filename links are named rtwIdGenFileLinks,
function removeHiliteFileList(winObj) {    
    removeHiliteByElementsName(winObj, "rtwIdGenFileLinks");
}

// Highlight TOC hyperlinks by their Ids.
function tocHiliteById(id) {
    hiliteColor = "#ffff99";    
    if (top && top.rtwreport_contents_frame && top.rtwreport_contents_frame.document) {
        removeHiliteCodeNav(top.rtwreport_contents_frame);
        setBGColorByElementId(top.rtwreport_contents_frame.document, id, hiliteColor);
    }
}

// onClick function to highlight the link itself
function tocHiliteMe(winObj, linkObj, bCleanTrace) {
    hiliteColor = "#ffff99";
    // remove the trace info (previous highlighted source code and the navigate
    // panel)
    // Clean Trace info only when links in TOC clicked. Links of filenames won't
    // clean trace info. 
    if (bCleanTrace && RTW_TraceInfo.instance) {
        RTW_TraceInfo.instance.setDisablePanel(true);
        rtwRemoveHighlighting();
    }        
    removeHiliteCodeNav(winObj);
    if (linkObj.parentNode) {
        linkObj.parentNode.style.backgroundColor= hiliteColor;
    }
}

// onClick function to clean the currently highlighed lines in document frame
// based on URL's hash
// Then highlight lines in document frame based on Element's name
// It works for links to some elements in the same page, otherwise, 
// rtwFileOnLoad() in loading page does the job.
function docHiliteMe(winObj, elementName) {
    // First, remove the highlighted elements by stored hash value
    removeHiliteByHash(winObj);
    // Store the new hash value defined by elementName
    if (RTW_Hash.instance) {
      RTW_Hash.instance.setHash("#"+elementName);
    } else {
      RTW_Hash.instance = new RTW_Hash("#"+elementName);
    }
    hiliteByElementsName(winObj, elementName);
}

// Callback for generated file load callback
function rtwFileOnLoad(docObj) {
  if (!docObj.location || !docObj.location.href)
      return;
  // Save the hash value when file is loaded in the first time
  if (!RTW_Hash.instance) {
     RTW_Hash.instance = new RTW_Hash(docObj.location.hash);
  } else {
     RTW_Hash.instance.setHash(docObj.location.hash);
  }  
   
  updateHyperlinks();
  // highlight lines in source code file according to the URL hash
  hiliteByHash(docObj);
  // highlight the filename in the TOC frame
  if (top.rtwreport_contents_frame) {
    if (hiliteByFileName(docObj.location.href)) {
        // remove the highlights in the TOC frame if filename is hilite successfully
        removeHiliteTOC(top.rtwreport_contents_frame);
    }
  }
     
  if (!RTW_TraceInfo.instance)
    return;
  if (!docObj.getElementById)
    return;
  if (rtwSrcFrame())
    rtwSrcFrame().focus();
  var fileName = rtwGetFileName(docObj.location.href);
  var fileIdx = RTW_TraceInfo.instance.getFileIdx(fileName);
  if (fileIdx != null) {
    if (fileIdx != RTW_TraceInfo.instance.getCurrFileIdx())
      RTW_TraceInfo.instance.setCurrent(fileIdx,-1);
    var codeNode = docObj.getElementById("RTWcode");
    var hiliteColor = RTW_TraceArgs.instance.getColor();
    if (!hiliteColor) {
        hiliteColor = "#aaffff";
    }
    var fontSize = RTW_TraceArgs.instance.getFontSize();
    if (fontSize) {
        codeNode.style.fontSize = fontSize;
    }
    RTW_TraceInfo.instance.highlightLines(codeNode,hiliteColor);
    RTW_TraceInfo.instance.highlightFileLink(fileIdx,"#ffff99");
  }
}

// Callback for "Prev" button
function rtwGoPrev() {
  if (RTW_TraceInfo.instance && top.rtwreport_document_frame) {
    var prevfileIdx = RTW_TraceInfo.instance.getPrevFileIdx();
    var currfileIdx = RTW_TraceInfo.instance.fCurrFileIdx;
    RTW_TraceInfo.instance.goPrev();
    top.rtwreport_document_frame.document.location.href=RTW_TraceInfo.instance.getCurrentHRef();
    if (prevfileIdx == currfileIdx) {
        if (top.rtwreport_contents_frame) {            
            if (hiliteByFileName(top.rtwreport_document_frame.location.href))
                removeHiliteTOC(top.rtwreport_contents_frame);
        }
    }
  }
}

// Callback for "Next" button
function rtwGoNext() {
  if (RTW_TraceInfo.instance && top.rtwreport_document_frame) {
    var nextfileIdx = RTW_TraceInfo.instance.getNextFileIdx();
    var currfileIdx = RTW_TraceInfo.instance.fCurrFileIdx;
    RTW_TraceInfo.instance.goNext();
    top.rtwreport_document_frame.document.location.href=RTW_TraceInfo.instance.getCurrentHRef();
    if (nextfileIdx == currfileIdx) {
        if (top.rtwreport_contents_frame) {     
            // remove TOC highlighted node only if hiliteByFileName successfully
            // hilights source filename node 
            if (hiliteByFileName(top.rtwreport_document_frame.location.href))
                removeHiliteTOC(top.rtwreport_contents_frame);
        }
    }
  }
}

// Helper function for main document load callback
function rtwMainOnLoadFcn(topDocObj,aLoc,aPanel,forceReload) {
  var loc;
  var aHash="";
  var lastArgs = null;
  var tocDocObj = top.rtwreport_contents_frame.document;
  if (typeof forceReload === "undefined") {
      forceReload = false;
  }
  // get the hash value from location.
  if (!aLoc) {
      loc = topDocObj.location;
      if (loc.search || loc.hash) {
          if (loc.search)
              aHash = loc.search.substring(1);
          else
              aHash = loc.hash.substring(1);
      }
  } else {
      aHash = aLoc;
      if (RTW_TraceArgs.instance)
          lastArgs = RTW_TraceArgs.instance;
  }
  // parse URL hash value
  RTW_TraceArgs.instance = new RTW_TraceArgs(aHash);
  if (lastArgs !== null) {
      RTW_TraceArgs.instance.setUseExternalBrowser(lastArgs.getUseExternalBrowser());
      RTW_TraceArgs.instance.setModel2CodeSrc(lastArgs.getModel2CodeSrc());
  }    

  // get highlight url using sid
  if (RTW_TraceArgs.instance.hasSid()) {
    sid = RTW_TraceArgs.instance.getSID();
    aHash = RTW_Sid2UrlHash.instance.getUrlHash(sid);    
  }
  // parse hash to look for msg=...&block=... pattern
  RTW_TraceArgs.instance.parseCommand(aHash);
  // parse hash to look for file.c:10,12&file.h:10,12 
  RTW_TraceArgs.instance.parseUrlHash(aHash);

  // hide navigation buttons if not in MATLAB
  if (RTW_TraceArgs.instance.getUseExternalBrowser() && tocDocObj.getElementById) {
      var o = tocDocObj.getElementById("nav_buttons");
      if (o != null) {
          o.style.display = "none";
      }
  }

  // hide web view frameset if model2code_src is model
  if (RTW_TraceArgs.instance.getModel2CodeSrc() === "model") {
      var o = top.document.getElementById('rtw_midFrame');
      if (o) {
          o.rows = "100%,0%";
      }
  }

  // modify modelref links
  if (tocDocObj.getElementsByName) {
      var arg = "";
      if (!RTW_TraceArgs.instance.getUseExternalBrowser()) {
          arg = "?useExternalBrowser=false";
      }
      if (RTW_TraceArgs.instance.getModel2CodeSrc() != null) {
          if (arg.length > 0)
              arg = arg + "&model2code_src=" + RTW_TraceArgs.instance.getModel2CodeSrc();
          else
              arg = "?model2code_src=" + RTW_TraceArgs.instance.getModel2CodeSrc();
      }
      if (arg.length > 0) {
          links = tocDocObj.getElementsByName('external_link');
          for (var link_idx = 0; link_idx < links.length; ++link_idx) {
              links[link_idx].href = links[link_idx].href + arg;
          }
      }
  }

  // stop onload when it has been loaded
  if (window.location.search.indexOf("loaded=true") > 0 
        && top.rtwreport_document_frame.location.href !== "about:blank" && forceReload !== true) {
      updateHyperlinks();
      return;
  }
  // redirect the page based on the url    
  var initPage = null;
  if (RTW_TraceArgs.instance.getNumFiles()) {
    var fileLinks = RTW_TraceInfo.getFileLinks(tocDocObj);
    RTW_TraceInfo.instance = new RTW_TraceInfo(fileLinks);
    RTW_TraceInfo.instance.removeHighlighting();
    var numFiles = RTW_TraceArgs.instance.getNumFiles();
    for (var i = 0; i < numFiles; ++i) {
      RTW_TraceInfo.instance.setLines(RTW_TraceArgs.instance.getFile(i),RTW_TraceArgs.instance.getLines(i));
    }
    if (aPanel == false) {
      RTW_TraceInfo.instance.setDisablePanel(true);
    }
    var initFile = RTW_TraceArgs.instance.getInitFile();
    RTW_TraceInfo.instance.setInitLocation(initFile,RTW_TraceArgs.instance.getInitLine());
    initPage = RTW_TraceInfo.instance.getCurrentHRef();
  } else {
      // catch error that document frame is in another domain
      try {
          var fileDocObj = top.rtwreport_document_frame.document;
          if (fileDocObj.location && (!fileDocObj.location.href || fileDocObj.location.href == "about:blank")) {
              var summaryPage = tocDocObj.getElementById("rtwIdSummaryPage");
              var tracePage = tocDocObj.getElementById("rtwIdTraceability");
              if (summaryPage) {
                  initPage = summaryPage.href;
              } else if (tracePage) {
                  initPage = tracePage;
              }
          }
      } catch(e) {};
  }
  if (RTW_TraceArgs.instance && RTW_TraceArgs.instance.fMessage) {
    // display diagnostic message
    var linkId = "rtwIdMsgFileLink";
    var msgFile = tocDocObj.getElementById(linkId);
    if (msgFile && msgFile.style) {
      msgFile.style.display = "block";
      // Highlight the background of msg link
      tocHiliteById(linkId);      
    }
    initPage = "rtwmsg.html";
  }
  if (initPage) {
      var is_same_page = false;
      try {
          var fileDocObj = top.rtwreport_document_frame.document;
          is_same_page = isSamePage(fileDocObj.location.href, initPage);
      } catch(e) {};          
      if (is_same_page) {
        top.rtwreport_document_frame.location.href = initPage;
        // Goto the same page won't trigger onload function.
        // Call it manuelly to highligh new code location.
          rtwFileOnLoad(top.rtwreport_document_frame.document);        
     } else {
        // change current fileDocObj to initPage
        top.rtwreport_document_frame.location.href = initPage;
     }
  }
}

// Compare if href1(i.e. file:///path/file1.html#222) and href2(i.e.file2.html) are same pages.
// isSamePage return true if file1 == file2.
function isSamePage(href1, href2) {
  var page1 = href1.substring(href1.lastIndexOf('/')+1,href1.lastIndexOf('.html'));
  var page2 = href2.substring(href2.lastIndexOf('/')+1,href2.lastIndexOf('.html'));
  return (page1 == page2);
}

// Callback for main document loading
function rtwMainOnLoad() {    
    rtwMainOnLoadFcn(document,null,true, false);
    // modify history state to avoid reload from pressing back 
    if (RTW_TraceArgs.instance && !RTW_TraceArgs.instance.getUseExternalBrowser() && 
        typeof window.history.replaceState === "function") {
        if (window.location.search.length > 0) {
            newUrl = document.location.pathname + window.location.search + '&loaded=true';
        } else {
            newUrl = document.location.pathname + window.location.search + '?loaded=true';
        }
        window.history.replaceState("","",newUrl);
    }
}

// Helper function for traceability report
function rtwMainReload(location) {
  // remove highlight filename and lines before reloading the page
  if (RTW_TraceInfo.instance)
     RTW_TraceInfo.instance.removeHighlighting();  
  rtwMainOnLoadFcn(document,location,true,true);
}

function rtwMainReloadNoPanel(location) {
  rtwMainOnLoadFcn(document,location,false,true);
}

// Callback for hyperlink "Remove Highlighting"
function rtwRemoveHighlighting() {
  if (RTW_TraceInfo.instance)
    RTW_TraceInfo.instance.removeHighlighting();
  if (rtwSrcFrame())
    rtwSrcFrame().focus();
}

// Display diagnostic message in document frame
function rtwDisplayMessage() {
  var docObj = top.rtwreport_document_frame.document;
  var msg = docObj.getElementById(RTW_TraceArgs.instance.fMessage);
  if (!msg) {
    msg = docObj.getElementById("rtwMsg_notTraceable");
  }
  if (msg && msg.style) {
    msg.style.display = "block"; // make message visible
    var msgstr = msg.innerHTML;
    if (RTW_TraceArgs.instance.fBlock) {
      // replace '%s' in message with block name
      msgstr = msgstr.replace("%s",RTW_TraceArgs.instance.fBlock);
    }
    msg.innerHTML = msgstr;
  }
}

function updateHyperlinks() {
    docObj = top.rtwreport_document_frame;
    if (docObj && docObj.document) {
        if (RTW_TraceArgs.instance === null || !RTW_TraceArgs.instance.getUseExternalBrowser()) {
            var plain_link =  docObj.document.getElementById("linkToText_plain");
            if (plain_link && plain_link.href && plain_link.href.indexOf("matlab:rtwprivate") === -1 ) {
                plain_link.href = "matlab:rtwprivate('editUrlTextFile','" + str2StrVar(plain_link.href) + "')";
            }          
            var alink = docObj.document.getElementById("linkToCS");
            if (alink && alink.href && alink.href.indexOf("matlab:rtwprivate") === -1) {
                alink.href = "matlab:rtwprivate('rtw_view_code_configset_from_report','" + str2StrVar(alink.href) + "');";
            }
        } else {
            var alink = docObj.document.getElementById("linkToCS");
            if (alink && alink.style) {
                alink.style.display = "none";
                hidden_link = docObj.document.getElementById("linkToCS_disabled");
                if (hidden_link)
                    hidden_link.style.display = "";
            }
            if (typeof docObj.document.getElementsByClassName === "function")
                alinks = docObj.document.getElementsByClassName("callMATLAB");
            else if (typeof docObj.document.getElementsByName === "function")
                alinks = docObj.document.getElementsByName("callMATLAB");
            else
                alinks = [];
            for (i = 0; i < alinks.length; i++) {
 		alinks[i].href = "javascript:alert('This hyperlink is available only in MATLAB browser.');";
                alinks[i].style.color = "gray";
            }
            alink = docObj.document.getElementById("CodeGenAdvCheck");
            if (alink && alink.href && alink.href.indexOf("externalweb=true")===-1) {
                alink.href = alink.href + "?externalweb=true";
            }

            if (typeof docObj.document.getElementsByName === "function") 
                var objs = docObj.document.getElementsByName("MATLAB_link");
            else 
                objs = [];
            for (var objIndex = 0; objIndex < objs.length; ++objIndex) {     
                objs[objIndex].style.display = "none";
            }
        }
    }
    updateCode2ModelLinks(docObj.document);
}

function rtwPageOnLoad(id) {
    // highlight toc entry
    tocHiliteById(id);
    // restore elements state
    if (top && top.restoreState) {
        if (top.rtwreport_contents_frame && top.rtwreport_contents_frame.document)
            top.restoreState(top.rtwreport_contents_frame.document);
        if (top.rtwreport_document_frame && top.rtwreport_document_frame.document)
            top.restoreState(top.rtwreport_document_frame.document);
    }
    updateHyperlinks();
}

// highlight code after changeSys
function rtwChangeSysCallback(sid) {
    if (sid == "" || typeof RTW_Sid2UrlHash == "undefined" || !RTW_Sid2UrlHash.instance)
        return false;
    urlHash = RTW_Sid2UrlHash.instance.getUrlHash(sid);
    if (urlHash != undefined) {
        if (!RTW_TraceArgs.instance.getUseExternalBrowser())
            urlHash = (urlHash == "")? "?useExternalBrowser=false" : 
                      urlHash+"&useExternalBrowser=false";
        rtwMainReload(urlHash, true);
        return true;
    } else {
        // remove highlighting from traceinfo
        rtwRemoveHighlighting();
        return false;
    }
}

// eml file onload function: highlight line in eml file
function emlFileOnload(docObj) {
    var loc = docObj.location;
    if (loc.hash) {
        var line = loc.hash.substring(1);
        hiliteEmlLine(docObj, line);		            
    }	
}

// highlight line in an eml file. Ynhighlight previously highligted line first.
function hiliteEmlLine(docObj, line) {
    var bgColor;
    if (top.HiliteCodeStatus)
        bgColor = "#66CCFF";
    else
        bgColor = "#E8D152";
    // unhighlight
    if (typeof docObj.HiliteLine != "undefined") {
	trObj = docObj.getElementById("LN_"+docObj.HiliteLine);
	if (trObj != null) {
	    trObj.style.backgroundColor = "";			
	}
    }	
    // hilighlight
    trObj = docObj.getElementById("LN_"+line);
    if (trObj != null) {
	trObj.style.backgroundColor = bgColor;
	docObj.HiliteLine = line;
    }
}
// eml line onclick callback: highlight C code and current line in eml file
function emlLineOnClick(docObj,sid,line) {
    if (top) {
	top.HiliteCodeStatus = top.rtwChangeSysCallback(sid);        
    }
    hiliteEmlLine(docObj, line);
}

function updateCode2ModelLinks(docObj) {
    var webviewFrame = top.document.getElementById('rtw_midFrame');
    if (webviewFrame) {
        if (RTW_TraceArgs.instance && 
            (RTW_TraceArgs.instance.getModel2CodeSrc() !== "model" ||
             RTW_TraceArgs.instance.getUseExternalBrowser())
           ) {
            hiliteCmd = "javascript:top.rtwHilite(";
        } else {
            hiliteCmd = "matlab:rtwprivate('code2model',";
        }
        var objs = docObj.getElementsByName('code2model');
        var o = null;
        var str = '';
        var pattern = "'code2model',";
        for (var objIndex = 0; objIndex < objs.length; ++objIndex) {     
            o = objs[objIndex];
            str = o.href.substring(o.href.indexOf('(')+1);
            if (str.indexOf(pattern) > -1) {
                str = str.substring(str.indexOf(pattern) + pattern.length);
            }
            o.href = hiliteCmd + str;
        }
    }
}

function rtwHilite(aBlock,aParentSID) {
    if (aBlock.indexOf('-') !== -1) { 
        // remove sid range: model:sid:2-10 => model:sid 
        var s; 
        s = aBlock.split(':'); 
        if (s.length > 0) { 
            s = s[s.length-1]; 
            if (s.indexOf('-') != -1) { 
                aBlock = aBlock.substring(0, aBlock.lastIndexOf(':')); 
            } 
        } 
    } 
    if (typeof aParentSID === "undefined") {
        if (top.RTW_SidParentMap && top.RTW_SidParentMap.instance)
            aParentSID = top.RTW_SidParentMap.instance.getParentSid(aBlock);
        else
            aParentSID = aBlock;
    }
    top.HiliteCodeStatus = true;
    if (hiliteBlockForRTWReport(aBlock,aParentSID) === false) {
        rtwHilite(aParentSID);
    }
}

function str2StrVar(str) {
    return str.replace(/'/g,"''");
}
window.onload=rtwMainOnLoad;

