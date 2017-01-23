var map;
google.load("earth", "1", {"other_params":"sensor=true_or_false"});

function init() {
  google.earth.createInstance('map3d', initCB, failureCB).addTo(map);
}

function initCB(instance) {
  map = instance;
  map.getWindow().setVisibility(true);
}

function failureCB(errorCode) {
}

google.setOnLoadCallback(init);