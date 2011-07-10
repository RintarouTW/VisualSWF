function setVisibility(element, visible) {
    if(visible) {
        element.style.visibility = "visible";
    } else {
        element.style.visibility = "hidden";
    }
}

function getStyle(element) {
    return getComputedStyle(element);
}

function getValue(element, key) {
	return parseInt(getStyle(element)[key], 10);
}


/* useFixed: depend on the CSS position:fixed. or use style.margin by default. */
function centerAlign(parentView, targetView, useFixed) {
    parentViewWidth  = getValue(parentView, "width");
    parentViewHeight = getValue(parentView, "height");
    
    targetViewWidth  = getValue(targetView, "width");
    targetViewHeight = getValue(targetView, "height");
    
    targetViewLeft   = (parentViewWidth - targetViewWidth) / 2;
    targetViewTop    = (parentViewHeight - targetViewHeight) / 2;
    
    if(targetViewLeft < 0)
        targetViewLeft = 0;

    if(targetViewTop < 0)
        targetViewTop = 0;
        
    if (useFixed) {
        targetView.style.top =  targetViewTop + 'px';
        targetView.style.left = targetViewLeft + 'px';
    } else {
        targetView.style.margin =  targetViewTop + 'px auto auto ' + targetViewLeft + 'px';
    }
    
    return true;
}

function isdefined(obj) {
	if (typeof(obj) != 'undefined')
		return true;
	else
		return false;
}