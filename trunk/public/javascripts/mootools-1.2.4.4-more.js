//MooTools More, <http://mootools.net/more>. Copyright (c) 2006-2009 Aaron Newton <http://clientcide.com/>, Valerio Proietti <http://mad4milk.net> & the MooTools team <http://mootools.net/developers>, MIT Style License.

MooTools.More={version:"1.2.4.4",build:"6f6057dc645fdb7547689183b2311063bd653ddf"};(function(d,e){var c=/(.*?):relay\(([^)]+)\)$/,b=/[+>~\s]/,f=function(g){var h=g.match(c);
return !h?{event:g}:{event:h[1],selector:h[2]};},a=function(m,g){var k=m.target;if(b.test(g=g.trim())){var j=this.getElements(g);for(var h=j.length;h--;
){var l=j[h];if(k==l||l.hasChild(k)){return l;}}}else{for(;k&&k!=this;k=k.parentNode){if(Element.match(k,g)){return document.id(k);}}}return null;};Element.implement({addEvent:function(j,i){var k=f(j);
if(k.selector){var h=this.retrieve("$moo:delegateMonitors",{});if(!h[j]){var g=function(m){var l=a.call(this,m,k.selector);if(l){this.fireEvent(j,[m,l],0,l);
}}.bind(this);h[j]=g;d.call(this,k.event,g);}}return d.apply(this,arguments);},removeEvent:function(j,i){var k=f(j);if(k.selector){var h=this.retrieve("events");
if(!h||!h[j]||(i&&!h[j].keys.contains(i))){return this;}if(i){e.apply(this,[j,i]);}else{e.apply(this,j);}h=this.retrieve("events");if(h&&h[j]&&h[j].keys.length==0){var g=this.retrieve("$moo:delegateMonitors",{});
e.apply(this,[k.event,g[j]]);delete g[j];}return this;}return e.apply(this,arguments);},fireEvent:function(j,h,g,k){var i=this.retrieve("events");if(!i||!i[j]){return this;
}i[j].keys.each(function(l){l.create({bind:k||this,delay:g,arguments:h})();},this);return this;}});})(Element.prototype.addEvent,Element.prototype.removeEvent);
