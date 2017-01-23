function MapClass(){
	var that = this;
	that.map;
	that.layer;
	that.intervalID;
	that._canSupport3d = true;
	that.ge;

	that.init = function(){
		if (that.canSupport3d()) {
			that.init3d();
			that.init2d(false);
		}
		else {
			$('#3d2dswap').css('display', 'none');
			that.init2d(true);
		}
	}
	
	that.init3d = function(){
		var placemark;
		var kmlObject;

		google.load("earth", "1", {"other_params":"sensor=false"});

		function init() {
			google.earth.createInstance('map3d', initCB, failureCB);
		}

		function initCB(instance) {
			ge = instance;
			ge.getWindow().setVisibility(true);
		 
			ge.getLayerRoot().enableLayerById(ge.LAYER_BUILDINGS, true);
      
			ge.getNavigationControl().setVisibility(instance.VISIBILITY_AUTO);

			var href = 'http://localhost/files/water_level.kmz';
			google.earth.fetchKml(ge, href, kmlFinishedLoading);
	
			placemark = ge.createPlacemark('');
		}

		function kmlFinishedLoading(kmlObject) {
			if (kmlObject) {
				if ('getFeatures' in kmlObject) {
					kmlObject.getFeatures().appendChild(placemark);
				}
				ge.getFeatures().appendChild(kmlObject);
				if (kmlObject.getAbstractView()){
					ge.getView().setAbstractView(kmlObject.getAbstractView());
				}
			}
		}

		function showHideKml() {
			kmlObject.setVisibility(!kmlObject.getVisibility());
		}

		function failureCB(errorCode) {
			that._canSupport3d = false;
		}

		google.setOnLoadCallback(init);	
	}
	
	that.init2d = function(show){
		if (show) {
			$("#map2d").css('display', 'block');
			$("#map3d").css('display', 'none');
			$("#to3d").css('display', 'block');
			$("#to2d").css('display', 'none');
		}
		else {
			$("#to3d").click();
		}

		that.map = L.map('map2d').setView([38.5732,-76.068949], 14);

		that.layer = new Array();

		that.layer[0] = L.tileLayer('http://a.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png', {
			attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://cloudmade.com">CloudMade</a>',
			maxZoom: 18
		});

		that.layer[1] = L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
			attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://cloudmade.com">CloudMade</a>',
			maxZoom: 18
		});

		that.layer[2] = L.tileLayer('http://otile1.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.png', {
			attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://cloudmade.com">CloudMade</a>',
			maxZoom: 18
		});

		that.layer[0].addTo(that.map);
		
		that.startAnimation(3000);
	}
	
	that.canSupport3d = function(){
		if (that._canSupport3d == false)
			return false;
		
		var browser = navigator.platform;
		if (browser == "MacPPC" || browser == "MacIntel" || browser == "Win32")
			return true;
	}
	
	that.getMap = function(){
		return that.map;
	}
	
	that.startAnimation = function(ms){
		if(that.intervalID != undefined){
			clearInterval(that.intervalID);
		}
		var i = 1;
		that.intervalID = setInterval(function(){
			that.map.removeLayer(that.layer[i]);
			i++;
			if(i==(that.layer.length-1)){
				i=0;
			}
			that.map.addLayer(that.layer[i]);
		},ms);
	}
}
