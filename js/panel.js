$('#to3d').on('click', function(e) {
	$("#map2d").css('display', 'none');
	$("#map3d").css('display', 'block');
	$("#to3d").css('display', 'none');
	$("#to2d").css('display', 'block');
});

$('#to2d').on('click', function(e) {
	$("#map2d").css('display', 'block');
	$("#map3d").css('display', 'none');
	$("#to3d").css('display', 'block');
	$("#to2d").css('display', 'none');
	map.invalidateSize();
});

 var mc = new MapClass();
mc.init();


var map = mc.getMap();

$('.dropdown-toggle').dropdown();
$('.btn-group').button()

$('#20').on('click', function (e) {
	mc.startAnimation(6000);
});

$('#50').on('click', function (e) {
	mc.startAnimation(4000);
});

$('#100').on('click', function (e) {
	mc.startAnimation(1000);
});

var hidden=false;

$("#paneltoggle").click(function() {
    var value = $("#paneltoggle").html();
	$("#panel").toggle();
	
	if(value == "Hide Panel") {
	  $("#paneltoggle").html('Show Panel');
	  $("#maps").attr("style", "width:100%;");
	  $("#maps").attr("style", "width:100%;");
	  L.Util.requestAnimFrame(map.invalidateSize,map,!1,map._container);

	  if ($("#to2d").css('display') == 'block') {
	  }
	} 
	else {
	  $("#paneltoggle").html('Hide Panel');
	  $("#maps").attr("style", "width:75%;");
	  $("#maps").attr("style", "width:75%;");
	}	
	 
	
});

//create a button over google earth
//from http://earth-api-samples.googlecode.com/svn/trunk/demos/customcontrols/index.html
function createNativeHTMLButton() {
  var btn = document.getElementById('paneltoggle');
  var btnRect = getElementRect(btn);
  
  // create the button
  var button = document.createElement('a');
  button.href = '#';
  button.className = 'tri-button';
  button.style.display = 'block';
  button.style.backgroundImage = 'url(btn_html.png)';
  button.style.backgroundColor = 'white';
  
  // create an IFRAME shim for the button
  var iframeShim = document.createElement('iframe');
  iframeShim.frameBorder = 0;
  iframeShim.scrolling = 'no';
  iframeShim.src = (navigator.userAgent.indexOf('MSIE 6') >= 0) ?
      '' : 'javascript:void(0);';

  // position the button and IFRAME shim
  var pluginRect = getElementRect(document.getElementById('map3d'));
  button.style.position = iframeShim.style.position = 'absolute';
  button.style.left = iframeShim.style.left = (pluginRect.left + btnRect.left) + 'px';
  button.style.top = iframeShim.style.top = (pluginRect.top + btnRect.top) + 'px';
  button.style.width = iframeShim.style.width = btn.style.width + 'px';
  button.style.height = iframeShim.style.height = btn.style.height + 'px';
  
  // set up z-orders
  button.style.zIndex = 10;
  iframeShim.style.zIndex = button.style.zIndex - 1;
  
  // set up click handler
  addDomListener(button, 'click', function(evt) {
    alert('You clicked the native HTML button!');
    
    if (evt.preventDefault) {
      evt.preventDefault();
      evt.stopPropagation();
    }
    return false;
  });
  
  // add the iframe shim and button
  document.body.appendChild(button);
  document.body.appendChild(iframeShim);
}
