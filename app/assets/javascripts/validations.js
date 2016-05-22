$(function () {

  Recurring.validations = {

    registrationChecks: function (form) {
      // check that required fields are not empty (inputs with class .js-validate and .required)

      form.find('[type="submit"]').on('click', function (e) {
        // STOP SUBMIT FORM
        e.preventDefault();

        var fields = form.find('.js-validate');

        if (fields.length > 0) {
          var errors = [];

          fields.each(function () {
            var field = $(this);
            if (field.hasClass('required') && (field.val() == '')) {
              errors.push(1);

              field.parent().addClass('has-error');
              field.on('keyup', function () {
                field.parent().removeClass('has-error');
              });
            }
          });

          if (errors.length == 0) {
            // SUBMIT FORM
            form.submit();
          }

        } else {
          // SUBMIT FORM
          form.submit();
        }
      });
    },

    init: function () {
      var this_ = this;

      var user_form = $('#new_user');
      if (user_form.length > 0) {
        this_.registrationChecks(user_form);
      }
    }
  };

  Recurring.validations.init();
});