window.IssueTemplates = function(){

  return {
    load_url: undefined,

    // checks if data has been entered manually
    //
    // does not take into account checklists, at all.
    dataChanged: function(){
      var subj = $('#issue_subject');
      var desc = $('#issue_description');
      return(
        // changed data tracks changes after a template was applied
        subj.data('changed') ||
        desc.data('changed') ||
        // this catches the case of a form reload due to tracker change where
        // data is present already. wrongly catches a previously applied (but
        // unchanged) template but we live with that - better to ask for
        // permission once too much than losing data.
        (!subj.data('original-value') && (subj.val() !== '')) ||
        (!desc.data('original-value') && (this.trim(desc.val()) !== ''))
      );
    },

    load: function(){
      var selected_template = $('#issue_template');
      if (selected_template.val() !== '') {
        $.get(this.load_url.replace('@TPL_ID@', selected_template.val()));
      }
    },

    clearChecklist: function(){
      var oldList = $('span.checklist-item.show:visible span.checklist-show-only.checklist-remove > a.icon.icon-del');
      oldList.each(function () {
          oldList.click();
      });
    },

    needToConfirmOverwrite: function () {
      // no manually entered data - not necessary to ask for permission to replace.
      if(!this.dataChanged())
        return false;

      var cookie_array = [];
      if (document.cookie != '') {
        var tmp = document.cookie.split('; ');
        for (var i = 0; i < tmp.length; i++) {
          var data = tmp[i].split('=');
          cookie_array[data[0]] = decodeURIComponent(data[1]);
        }
      }
      var confirmation_cookie = cookie_array['issue_template_confirm_to_replace_hide_dialog'];
      if (confirmation_cookie == undefined || parseInt(confirmation_cookie) == 0) {
        return true;
      }
      return false;
    },

    trim: function(s) {
      return s.replace(/(?:\r\n|\r|\n)/g, '').trim();
    }

  };
}();


$(function () {
    $('a.template-disabled-link').click(function(event){
      var a = $(event.target);
      var msg = a.data("error");
      if (msg.length && a.attr('disabled')) {
        event.stopPropagation();
        alert(msg);
        return false;
      }
    });

    // Hide overwrite confirmation dialog using cookie.
    $('#issue_template_confirm_to_replace_hide_dialog').click(function () {
      if ($(this).is(':checked')) {
        // NOTE: Use document.cookie because Redmine itself does not use jquery.cookie.js.
        document.cookie = 'issue_template_confirm_to_replace_hide_dialog=1';
      } else {
        document.cookie = 'issue_template_confirm_to_replace_hide_dialog=0';
      }
    });
});

