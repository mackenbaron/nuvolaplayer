/*
 * Copyright 2014 Jiří Janoušek <janousek.jiri@gmail.com>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met: 
 * 
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer. 
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution. 
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


/**
 * Replaces placeholders in a template string with provided data.
 * 
 * Placeholders are in form of ``{n}`` where ``n`` is index of data argument starting at 1.
 * Special placeholders are ``{-1}`` for ``{`` and ``{-2}`` for ``}``.
 * 
 * @param String template    template string
 * @param Variant data...    other arguments will be used as data for replacement
 * @return String
 * 
 * ```js
 * alert(Nuvola.format("My name is {2}. {1} {2}!", "James", "Bond"));
 * // "My name is Bond. James Bond!"
 * 
 * // You can create an alias
 * var $fmt = Nuvola.format;
 * alert($fmt("My name is {2}. {1} {2}!", "James", "Bond"));
 * ```
 */
Nuvola.format = function()
{
    var args = arguments;
    return args[0].replace(Nuvola.format._regex, function (item)
    {
        var index = parseInt(item.substring(1, item.length - 1));
        if (index > 0)
            return typeof args[index] !== 'undefined' ? args[index] : "";
        else if (index === -1)
            return "{";
        else if (index === -2)
            return "}";
        return "";
    });
};


Nuvola.formatVersion = function(encodedVersion)
{
    var micro = encodedVersion % 100;
    encodedVersion = (encodedVersion - micro)/100;
    var minor = encodedVersion % 100;
    var major = (encodedVersion - minor)/100;
    return major + "." + minor + "." + micro;
};

Nuvola.format._regex = new RegExp("{-?[0-9]+}", "g");

Nuvola.inArray = function(array, item)
{
    return array.indexOf(item) > -1;
}

/**
 * Triggers mouse event on element
 * 
 * @param HTMLElement elm    Element object
 * @param String name        Event name
 */
Nuvola.triggerMouseEvent = function(elm, name)
{
    var event = document.createEvent('MouseEvents');
    event.initMouseEvent(name, true, true, document.defaultView, 1, 0, 0, 0, 0, false, false, false, false, 0, elm);
    elm.dispatchEvent(event);
}

/**
 * Simulates click on element
 * 
 * @param HTMLElement elm    Element object
 */
Nuvola.clickOnElement = function(elm)
{
    Nuvola.triggerMouseEvent(elm, 'mouseover');
    Nuvola.triggerMouseEvent(elm, 'mousedown');
    Nuvola.triggerMouseEvent(elm, 'mouseup');
    Nuvola.triggerMouseEvent(elm, 'click');
}

/**
 * Creates HTML text node
 * 
 * @param String text    text of the node
 * @return    new text node
 */
Nuvola.makeText = function(text)
{
    return document.createTextNode(text);
}

/**
 * Creates HTML element
 * 
 * @param String name          element name
 * @param Object attributes    element attributes (optional)
 * @param String text          text of the element (optional)
 * @return new HTML element
 */
Nuvola.makeElement = function(name, attributes, text)
{
    var elm = document.createElement(name);
    attributes = attributes || {};
    for (var key in attributes)
        elm.setAttribute(key, attributes[key]);
    
    if (text !== undefined && text !== null)
        elm.appendChild(Nuvola.makeText(text));
    
    return elm;
}

/**
 * Compares own properties of two objects
 * 
 * @param Object object1    the first object to compare
 * @param Object object2    the second object to compare
 * @return Array of names of different properties
 */
Nuvola.objectDiff = function(object1, object2)
{
    var changes = [];
    for (var property in object1)
    {
        if (object1.hasOwnProperty(property)
        && (!object2.hasOwnProperty(property) || object1[property] !== object2[property]))
            changes.push(property);
    }
    
    return changes;
}
