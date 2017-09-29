/********************************************* CK Editor (Html Editor) ******************************************************/
var arrCKEditor = new Array();

function SetCKEditor(Id, onBlurCallBack) {

    var $target = $('#' + Id);

    // The inline editor should be enabled on an element with "contenteditable" attribute set to "true".
    // Otherwise CKEditor will start in read-only mode.

    $target.attr('contenteditable', true);

    CKEDITOR.inline(Id,
        {
            // Show toolbar on startup (optional).
            //startupFocus: true,
            startupFocus: false,
            enterMode: CKEDITOR.ENTER_BR,
            on: {
                blur: function (event) {
                    event.editor.updateElement();
                },
                fileUploadResponse: function (evt) {
                    // Prevent the default response handler.
                    evt.stop();

                    // Ger XHR and response.
                    var data = evt.data,
                        xhr = data.fileLoader.xhr,
                        response = xhr.responseText.split('|');

                    var jsonarray = JSON.parse(response[0]);

                    if (jsonarray && jsonarray.uploaded != "1") {
                        // Error occurred during upload.                
                        evt.cancel();
                    } else {
                        data.url = jsonarray.url;
                    }
                }
            }
        });

    var editor = CKEDITOR.instances[Id];

    //console.log(editor.name + ' editor created.');

    arrCKEditor.push(editor);

    // Commented yogesh keraliya : 02152017 
    // Editor blur event auto update of underlying element.
    //editor.on('blur', function (event) {

    //    event.editor.updateElement();

    //    if (typeof (onBlurCallBack) == 'function') {
    //        console.log(event.editor.name + ' editor lost focus.');
    //        onBlurCallBack(event.editor);
    //    }
    //});

    //editor.on('fileUploadResponse', function (evt) {
    //    // Prevent the default response handler.
    //    evt.stop();

    //    // Ger XHR and response.
    //    var data = evt.data,
    //        xhr = data.fileLoader.xhr,
    //        response = xhr.responseText.split('|');

    //    var jsonarray = JSON.parse(response[0]);

    //    if (jsonarray && jsonarray.uploaded != "1") {
    //        // Error occurred during upload.                
    //        evt.cancel();
    //    } else {
    //        data.url = jsonarray.url;
    //    }
    //});
}

function SetCKEditorForPageContent(Id, AutosavebuttonId) {

    var $target = $('#' + Id);

    // The inline editor should be enabled on an element with "contenteditable" attribute set to "true".
    // Otherwise CKEditor will start in read-only mode.

    $target.attr('contenteditable', true);

    CKEDITOR.inline(Id,
        {
            // Show toolbar on startup (optional).
            //startupFocus: true,
            startupFocus: false,
            enterMode: CKEDITOR.ENTER_BR,
            on: {
                blur: function (event) {
                    event.editor.updateElement();
                    $(AutosavebuttonId).click();
                },
                fileUploadResponse: function (event) {
                    // Prevent the default response handler.
                    event.stop();

                    // Ger XHR and response.
                    var data = event.data,
                        xhr = data.fileLoader.xhr,
                        response = xhr.responseText.split('|');

                    var jsonarray = JSON.parse(response[0]);

                    if (jsonarray && jsonarray.uploaded != "1") {
                        // Error occurred during upload.                
                        event.cancel();
                    } else {
                        data.url = jsonarray.url;
                    }
                }

            }
        });

    var editor = CKEDITOR.instances[Id];

    arrCKEditor.push(editor);
}

function SetCKEditorForSubTask(Id) {

    var $target = $('#' + Id);

    // The inline editor should be enabled on an element with "contenteditable" attribute set to "true".
    // Otherwise CKEditor will start in read-only mode.

    $target.attr('contenteditable', true);

    CKEDITOR.inline(Id,
        {
            // Show toolbar on startup (optional).
            //startupFocus: true,
            startupFocus: false,
            enterMode: CKEDITOR.ENTER_BR,
            on: {
                blur: function (event) {
                    event.editor.updateElement();
                    //updateDesc(GetCKEditorContent(Id));
                },
                fileUploadResponse: function (event) {
                    // Prevent the default response handler.
                    event.stop();

                    // Ger XHR and response.
                    var data = event.data,
                        xhr = data.fileLoader.xhr,
                        response = xhr.responseText.split('|');

                    var jsonarray = JSON.parse(response[0]);

                    attachImagesByCKEditor(event.data.fileLoader.fileName, jsonarray.fileName);

                    if (jsonarray && jsonarray.uploaded != "1") {
                        // Error occurred during upload.                
                        event.cancel();
                    } else {
                        data.url = jsonarray.url;
                    }
                }

            }
        });

    var editor = CKEDITOR.instances[Id];

    arrCKEditor.push(editor);
}

function GetCKEditorContent(Id) {

    var editor = CKEDITOR.instances[Id];

    var encodedHTMLData = editor.getData();

    //editor.updateElement();

    //CKEDITOR.instances[Id].destroy();

    return encodedHTMLData;
}

function DestroyCKEditors() {
    for (var i = 0; i < arrCKEditor.length; i++) {
        if (typeof (arrCKEditor[i]) != 'undefined') {
            arrCKEditor[i].updateElement();
            //arrCKEditor[i].removeAllListeners();
        }
    }

    setTimeout(StartDestroying, 1);

    function StartDestroying() {
        for (var i = 0; i < arrCKEditor.length; i++) {
            if (typeof (arrCKEditor[i]) != 'undefined') {
                arrCKEditor[i].destroy();
            }
            console.log(arrCKEditor[i].name + ' editor destroyed.');
        }
        arrCKEditor = new Array();
    }
}

/********************************************* Dialog (jQuery Ui Popup) ******************************************************/
function ShowPopupWithTitle(varControlID, strTitle) {
    var windowWidth = (parseInt($(window).width()) / 2) - 10;

    var dialogwidth = windowWidth + "px";

    if ($(varControlID).attr('data-width')) {
        dialogwidth = $(varControlID).attr('data-width');
    }

    var objDialog = $(varControlID).dialog({ width: dialogwidth, height: "auto" });

    // this will update title of current dialog.
    objDialog.parent().find('.ui-dialog-title').html(strTitle);

    // this will enable postback from dialog buttons.
    objDialog.parent().appendTo(jQuery("form:first"));
}

function HidePopup(varControlID) {
    $(varControlID).dialog("close");
}

/********************************************* Dropzone (File upload on drag - drop) ******************************************************/
var arrDropzone = new Array();

function GetWorkFileDropzone(strDropzoneSelector, strPreviewSelector, strHiddenFieldIdSelector, strButtonIdSelector) {
    var strAcceptedFiles = '';
    if ($(strDropzoneSelector).attr("data-accepted-files")) {
        strAcceptedFiles = $(strDropzoneSelector).attr("data-accepted-files");
    }

    var strUrl = 'taskattachmentupload.aspx';
    switch ($(strDropzoneSelector).attr("data-upload-path-code")) {
        case '1':
            strUrl = 'userbulkupload.aspx';
            break;
        default:
            strUrl = 'taskattachmentupload.aspx';
            break;
    }

    var objDropzone = new Dropzone(strDropzoneSelector,
        {
            maxFiles: 5,
            url: strUrl,
            thumbnailWidth: 90,
            thumbnailHeight: 90,
            acceptedFiles: strAcceptedFiles,
            previewsContainer: strPreviewSelector,
            init: function () {
                this.on("maxfilesexceeded", function (data) {
                    //var res = eval('(' + data.xhr.responseText + ')');
                    alert('you are reached maximum attachment upload limit.');
                });

                // when file is uploaded successfully store its corresponding server side file name to preview element to remove later from server.
                this.on("success", function (file, response) {
                    var filename = response.split("^");
                    $(file.previewTemplate).append('<span class="server_file">' + filename[0] + '</span>');
                    AddAttachmenttoViewState(filename[0] + '@' + file.name, strHiddenFieldIdSelector);
                    if (typeof (strButtonIdSelector) != 'undefined' && strButtonIdSelector.length > 0) {
                        // saves attachment.
                        $(strButtonIdSelector).click();
                        //this.removeFile(file);
                    }
                });

                //when file is removed from dropzone element, remove its corresponding server side file.
                //this.on("removedfile", function (file) {
                //    var server_file = $(file.previewTemplate).children('.server_file').text();
                //    RemoveTaskAttachmentFromServer(server_file);
                //});

                // When is added to dropzone element, add its remove link.
                //this.on("addedfile", function (file) {

                //    // Create the remove button
                //    var removeButton = Dropzone.createElement("<a><small>Remove file</smalll></a>");

                //    // Capture the Dropzone instance as closure.
                //    var _this = this;

                //    // Listen to the click event
                //    removeButton.addEventListener("click", function (e) {
                //        // Make sure the button click doesn't submit the form:
                //        e.preventDefault();
                //        e.stopPropagation();
                //        // Remove the file preview.
                //        _this.removeFile(file);
                //    });

                //    // Add the button to the file preview element.
                //    file.previewElement.appendChild(removeButton);
                //});
            }

        });

    arrDropzone.push(objDropzone);

    return objDropzone;
}

function DestroyDropzones() {
    for (var i = 0; i < arrDropzone.length; i++) {
        arrDropzone[i].destroy();
    }
    arrDropzone = new Array();
}

/********************************************* Image Gallery ******************************************************/
var subtaskSliders;

function LoadImageGallery(strSelector) {

    if (typeof ($.fn.lightSlider) == 'function') {
        subtaskSliders = $(strSelector).lightSlider({
            gallery: true,
            item: 1,
            thumbItem: 9,
            slideMargin: 0,
            speed: 500,
            auto: true,
            loop: true,
            onSliderLoad: function () {
                $(strSelector).removeClass('cS-hidden');
            }
        });
    }
}


function DestroyGallery() {
    if (subtaskSliders && typeof (subtaskSliders.destroy) == 'function') {
        subtaskSliders.destroy();
    }
}
/********************************************* Chosen Dropdown Functions ******************************************************/
function ChosenDropDown(options) {
    var _options = options || {};
    $('.chosen-select').chosen(_options);
}

/********************************************* jQuery Ajax Functions ******************************************************/
function CallJGWebService(strWebMethod, objPostDataJSON, OnSuccessCallBack, OnErrorCallBack) {
    ShowAjaxLoader();
    $.ajax
    (
        {
            url: '../WebServices/JGWebService.asmx/' + strWebMethod,
            contentType: 'application/json; charset=utf-8;',
            type: 'POST',
            dataType: 'json',
            data: JSON.stringify(objPostDataJSON),
            asynch: false,
            success: function (data) {
                HideAjaxLoader();
                if (typeof (OnSuccessCallBack) === 'function') {
                    OnSuccessCallBack(data);
                }
            },
            error: function (a, b, c) {
                HideAjaxLoader();
                console.log('jQuery ajax error.');
                console.log(a);
                console.log(b);
                console.log(c);
                if (typeof (OnErrorCallBack) === 'function') {
                    OnErrorCallBack(a, b, c);
                }
            }
        }
    );
}

/********************************************* General Functions ******************************************************/
function htmlEncode(value) {
    //create a in-memory div, set it's inner text(which jQuery automatically encodes)
    //then grab the encoded contents back out.  The div never exists on the page.
    return $('<div/>').text(value).html();
}

function htmlDecode(value) {
    return $('<div/>').html(value).text();
}

function ShowAjaxLoader() {
    $('.loading').show();
}

function HideAjaxLoader() {
    $('.loading').hide();
}

function AddAttachmenttoViewState(serverfilename, hdnControlID) {

    var attachments;

    if ($(hdnControlID).val()) {
        attachments = $(hdnControlID).val() + serverfilename + "^";
    }
    else {
        attachments = serverfilename + "^";
    }

    $(hdnControlID).val(attachments);
}

function copyToClipboard(strDataToCopy) {
    window.prompt("Copy to clipboard: Ctrl+C, Enter", strDataToCopy);

    //var $temp = $('<button/>', {
    //    id: 'btnClipBoardContext'
    //});

    //$temp.attr("data-clipboard-text",strDataToCopy);
    //$temp.attr("class", "contextcopy");

    //$("body").append($temp);

    //var clipboard = new Clipboard('.contextcopy');

    //clipboard.on('success', function (e) {       
    //    console.info('Text:', e.text);
    //   e.clearSelection();
    //});


    // $temp.remove();

    //clipboard.destroy();
}

// gets value of a parameter from query string.
function GetQueryStringParameterValue(param) {
    var url = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for (var i = 0; i < url.length; i++) {
        var urlparam = url[i].split('=');
        if (urlparam[0] == param) {
            return urlparam[1];
        }
    }
}

//common code check query string parameter, if already exists then replace value else add that parameter. 
function updateQueryStringParameter(uri, key, value, Mainkey, MainValue) {
    var re = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
    var separator = uri.indexOf('?') !== -1 ? "&" : "?";

    if (uri.match(re)) {
        return uri.replace(re, '$1' + key + "=" + value + '$2');
    }
    else {
        uri = uri.replace("ITDashboard", "TaskGenerator");
        return uri + separator + Mainkey + "=" + MainValue + '&' + key + "=" + value;
    }
}

function updateQueryStringParameterTP(uri, key, value) {
    var re = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
    var separator = uri.indexOf('?') !== -1 ? "&" : "?";
    if (uri.match(re)) {
        return uri.replace(re, '$1' + key + "=" + value + '$2');
    }
    else {
        return uri + separator + key + "=" + value;
    }
}
function IsNumeric(e, blWholeNumber) {
    var keyCode = e.which ? e.which : e.keyCode;

    if (keyCode >= 48 && keyCode <= 57) {
        return true; // 0-9    
    }
    else if (keyCode == 9) {
        return true; // tab 
    }
    else if (keyCode == 37 || keyCode == 38) {
        return true; // left - right arrow
    }
    else if (keyCode == 8 || keyCode == 46) {
        return true; // back space - delete
    }
    else if (!blWholeNumber && keyCode == 190) {
        if (this.value.indexOf('.') == -1) {
            return true; // period
        }
    }
    return false;
}

function ScrollTo(target) {
    //console.log(target);
    //  console.log('Scroll to called for ' + target.Id);
    if (target.length > 0) {
        var offset = target.offset();
        if (typeof (offset) != 'undefined' && offset != null) {
            $('html, body').animate({
                scrollTop: offset.top
            }, 1000);
        }
    }
}
