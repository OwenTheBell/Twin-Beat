// Generated by CoffeeScript 1.3.3

/*
This is a wrapper class that handles adding a canvas entity to the DOM as well
as ensuring that everything draws to that canvas. This abstracts the need to 
handle contexts with other objects as well as covering prerendering.
*/


(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.WrapCanvas = (function() {

    function WrapCanvas() {
      this.zoom = 1;
      this.angle = 0;
      this.width = g.width;
      this.height = g.height;
      this.canvas = document.createElement('canvas');
      this.canvas.width = this.width;
      this.canvas.height = this.height;
      this.context = this.canvas.getContext('2d');
    }

    WrapCanvas.prototype.clear = function() {
      return this.context.clearRect(0, 0, this.width, this.height);
    };

    WrapCanvas.prototype.update = function() {
      this.canvas.width = this.width;
      return this.canvas.height = this.height;
    };

    WrapCanvas.prototype.draw = function() {};

    return WrapCanvas;

  })();

  window.DrawCanvas = (function(_super) {

    __extends(DrawCanvas, _super);

    function DrawCanvas() {
      DrawCanvas.__super__.constructor.apply(this, arguments);
      this.context.strokeStyle = '#000000';
    }

    DrawCanvas.prototype.draw = function(rCanvas) {
      return rCanvas.drawCanvas(this.canvas);
    };

    DrawCanvas.prototype.drawFill = function(entity) {
      var x, y;
      x = Math.floor(entity.x);
      y = Math.floor(entity.y);
      this.context.save();
      if (this.context.fillStyle !== entity.color) {
        this.context.fillStyle = entity.color;
      }
      this.context.fillRect(x, y, entity.width, entity.height);
      return this.context.restore();
    };

    DrawCanvas.prototype.drawFillBorder = function(entity) {
      var x, y;
      this.drawFill(entity);
      x = entity.x;
      y = entity.y;
      return this.context.strokeRect(x, y, entity.width, entity.height);
    };

    return DrawCanvas;

  })(WrapCanvas);

  /*
  	This classes is specifically designed to take input canvases and draw them
  	to the screen. This lets me easily layer canavs, change the order of the
  	layering, and rotate the layered canvases.
  */


  window.RenderCanvas = (function(_super) {

    __extends(RenderCanvas, _super);

    function RenderCanvas() {
      RenderCanvas.__super__.constructor.apply(this, arguments);
      this.renderCanvas = document.createElement('canvas');
      this.renderCanvas.width = g.width;
      this.renderCanvas.height = g.height;
      this.renderContext = this.renderCanvas.getContext('2d');
      $('#twinbeat').append(this.renderCanvas);
    }

    RenderCanvas.prototype.update = function() {};

    RenderCanvas.prototype.clear = function() {
      this.context.clearRect(0, 0, g.width, g.height);
      return this.renderContext.clearRect(0, 0, g.width, g.height);
    };

    RenderCanvas.prototype.draw = function() {
      return this.renderContext.drawImage(this.canvas, 0, 0, g.width, g.height);
    };

    RenderCanvas.prototype.hardTextDraw = function(text, left, top, font, fontSize, color) {
      this.context.font = fontSize + ' ' + font;
      this.context.fillStyle = color;
      return this.context.fillText(text, left, top);
    };

    RenderCanvas.prototype.drawCanvas = function(canvas) {
      var halfH, halfW;
      halfW = Math.floor(this.width / 2);
      halfH = Math.floor(this.height / 2);
      this.context.save();
      this.context.translate(halfW, halfH);
      if (canvas.angle !== 0) {
        this.context.rotate(canvas.angle);
      }
      this.context.drawImage(canvas.canvas, 0, 0, canvas.width, canvas.height, -halfW * canvas.zoom, -halfH * canvas.zoom, canvas.width * canvas.zoom, canvas.height * canvas.zoom);
      return this.context.restore();
    };

    return RenderCanvas;

  })(WrapCanvas);

}).call(this);