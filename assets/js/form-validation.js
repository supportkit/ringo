// Form validation - register form
	toastr.options = {"positionClass": "toast-top-full-width"};
    $('.form-register').validate({
      messages: {
        fullname: "Please enter your fullname",
        password: {
          required: "Please provide a password",
          minlength: "Your password must be at least 5 characters long"
        },
        confirmPassword: {
          required: "Please provide a password",
          minlength: "Your password must be at least 5 characters long",
          equalTo: "Please enter the same password as above"
        },
        email: "Please enter a valid email address"
      },      
      submitHandler: function(form) {
        var $this = $(form);
        $.ajax({
          url: $this.attr('action'),
          type: 'POST',
          data: $this.serialize(),
        })
        .done(function(msg) {
          if( msg == 'ok' ) {
            toastr.success('Thank you for signing up. Our manager will contact you soon!');
            $this[0].reset();
          } else {
            toastr.error('An error occured. Please try again later.');
          }
        })
        .fail(function() {
          toastr.error('An error occured. Please try again later.');
        });
      }      
    });
