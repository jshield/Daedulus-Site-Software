var Page;

$(document).ready(function () {
  $('span').hide();
  $('span.pbody').show();
  Page = new page();
});



function page() {
  this.mainbox = $('#mainbox');
  this.userbox = $('#userbox');
  this.forms = new Object();
  this.forms["npst"] = new form("New Topic", null, "loadIndex();");
  this.forms["login"] = new form("Login", null, "loadUserBox();");
  this.forms["register"] = new form("Register", "validate_registration();", "loadUserBox();");
  this.forms["quote"] = new form("Quote Post", null, "loadTopic(this.oid);");
  this.forms["update"] = new form("Update Post", null, "loadTopic(this.oid);");
  this.forms["reply"] = new form("Reply to Topic", null, "loadTopic(this.oid);");
  this.forms["password"] = new form("Change Password", null, "loadUserBox();");
  this.forms["status"] = new form("Update Status", null, "loadUserBox();");
  this.forms["addweapon"] = new form("Add Weapon to Database", null, "loadUserBox();");
  this.forms["shootuser"] = new form("Shoot User", null, "loadPage('livefeed');")
  this.dialog = null;
};



function form(title, validate, callback) {
  this.title = title;
  this.validate = function () {
    return eval(validate);
  };
  this.callback = function () {
    eval(callback)
  };
  this.elem;
  this.oid;
  this.url;
  this.name;
};



function flash(span, msg) {
  $("span." + span).css("color", "red");
  $("span." + span).text(msg).show().fadeOut(3000);
};



function showForm(name, id) {
  var form = Page.forms[name];
  form.name = name;
  if (id != null) {
    form.oid = id;
    form.url = "/api/" + name + "/" + id;
  } else if (id == null) {
    form.url = "/api/" + name;
  }
  boxyform(form);
};



function validate_registration() {
	var fail = false;
  if ($("input.register.user").val() == "Username") {
    flash("username", "!");
    fail = true;
  };
  if ($("input.register.disp").val() == "Display Name") {
    flash("dispname", "!");
    fail = true;
  };
  if ($("input.register.email").val() == "Email Address") {
    flash("email", "!");
    fail = true;
  };
  if ($("input.register.pass").val() == "Password") {
    flash("pass", "!");
    fail = true;
  };
  if ($("input.register.pass2").val() != $("input.register.pass").val()) {
    flash("pass2", "!=");
    fail = true;
  };
  if (fail == true) {
    return false;
  };
};



function boxyform(form) {
  dialog = Page.dialog;
  if (dialog != null) {
    dialog.show();
    return true;
  } else if (dialog == null) {
    dialog = new Boxy(null, {
      title: form.title,
      show: false,
      closable: true,
      hideFade: true,
      hideShrink: false,
      FadeIn: true,
      afterHide: function (d) {
        dialog.unload();
        dialog = null;
      },
      behaviours: function (d) {
        d.find("#" + form.name).submit(function () {
          if (form.validate != null) {
            if (form.validate() == false) {
              return false;
            }
          }
          Boxy.get(this).setContent("<div style = \"min-width:100px; min-height:50px\">Sending...</div>");
          $.post("/api/" + form.name, d.find("#" + form.name).serialize(), function (data) {
            form.callback();
            dialog.hideAndUnload();
          });
          return false;
        });
      }
    });
    dialog.setContent("<div style = \"min-width:100px; min-height:50px; text-align:right;\"><form id =\"" + form.name + "\"></form></div>");
    form.elem = $("#" + form.name);
    form.elem.load(form.url, function () {
      dialog.show();
      form.elem.find("textarea:first").focus();
      dialog.center();
    });
  };
}



function loadIndex() {
  Page.mainbox.hide();
  Page.mainbox.load('/api/topic/list/haml', null, function () {
    Page.mainbox.fadeIn(2000);
    Page.last = "/api/topic/list/haml";
  });
};



function loadTopic(id) {
  Page.mainbox.hide();
  Page.mainbox.load('/api/post/list/haml/' + id, null, function () {
    Page.mainbox.fadeIn(2000);
  });
};



function loadProfile(id) {
  Page.mainbox.hide();
  Page.mainbox.load('/api/user/profile/haml/' + id, null, function () {
    Page.mainbox.fadeIn(2000);
  });
};



function loadUserBox() {
  Page.userbox.hide();
  Page.userbox.load('/api/userbox', null, function () {
    Page.userbox.fadeIn(2000);
  });
};



function loadPage(pagename) {
  if (pagename == "forum") {
    loadUserBox();
    loadIndex();
    return true;
  } else if (pagename == "livefeed") {
    loadUserBox();
    Page.mainbox.hide();
    Page.mainbox.load('/api/status/list', null, function () {
      Page.mainbox.fadeIn(2000);
    });
  }
};

function logout() {
  var auth
  $.post("/user/logout", auth, function (data) {
    loadUserBox();
  });
};



function deletePost(id) {
  Page.dialog = new Boxy.confirm("Delete Post?", function () {
    $('#reply-' + id).load('/api/post/delete/' + id);
    Page.dialog = null;
  });
};
