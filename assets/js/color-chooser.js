
	jQuery("#style-switcher a.color").click(function() { 
	
		jQuery("#mainstyle").attr("href",'assets/css/'+jQuery(this).attr('title')+'.css');

		var color = jQuery(this).data('color');
		var cnt = 0;

		return false;
	});

	jQuery(".style-toggle").click(function(){
		var switcher = jQuery('#style-switcher');
			if (switcher.hasClass('style-active')){
				switcher.animate({marginLeft:'0'}, 300, 'linear');
			} else {
				switcher.animate({marginLeft:'225'}, 300, 'linear');
			}
		switcher.toggleClass('style-active');
		return false;
	});

		var width = jQuery(window).width();
		if (width < 768){jQuery('#awwwards').css('display', 'none');}
