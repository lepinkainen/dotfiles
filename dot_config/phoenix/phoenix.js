Phoenix.notify("Config loaded");

const MOD = ["command", "option", "control", "shift"];

//require("./constants.js");
// TODO: This moves so slowly, I want instant movement...
// require("./movement.js");

// Hyper key
var screen = Screen.main().flippedVisibleFrame();

var fullWidth = screen.width;
var fullHeight = screen.height;

var halfWidth = screen.width / 2;
var halfHeight = screen.height / 2;

var thirdWidth = screen.width / 3;

// maximise
Key.on("return", MOD, () => {
  const window = Window.focused();

  if (window) {
    window.setTopLeft({
      x: screen.x,
      y: screen.y,
    });
    window.setSize({
      width: fullWidth,
      height: fullHeight,
    });
  }
});

// top half
Key.on("up", MOD, () => {
  const window = Window.focused();

  if (window) {
    window.setTopLeft({
      x: screen.x,
      y: screen.y,
    });
    window.setSize({
      width: fullWidth,
      height: halfHeight,
    });
  }
});

// bottom half
Key.on("down", MOD, () => {
  const window = Window.focused();

  if (window) {
    window.setTopLeft({
      x: screen.x,
      y: screen.y + halfHeight,
    });
    window.setSize({
      width: fullWidth,
      height: halfHeight,
    });
  }
});

// right half
Key.on("right", MOD, () => {
  const window = Window.focused();

  if (window) {
    window.setTopLeft({
      x: screen.x + screen.width / 2,
      y: screen.y,
    });
    window.setSize({
      width: screen.width / 2,
      height: fullHeight,
    });
  }
});

// left half
Key.on("left", MOD, () => {
  const window = Window.focused();

  if (window) {
    window.setTopLeft({
      x: screen.x,
      y: screen.y,
    });
    window.setSize({
      width: screen.width / 2,
      height: fullHeight,
    });
  }
});

// top right
Key.on("i", MOD, () => {
  const window = Window.focused();

  if (window) {
    window.setTopLeft({
      x: screen.x + screen.width / 2,
      y: screen.y,
    });
    window.setSize({
      width: screen.width / 2,
      height: halfHeight,
    });
  }
});
// Top left
Key.on("u", MOD, () => {
  const window = Window.focused();

  if (window) {
    window.setTopLeft({
      x: screen.x,
      y: screen.y,
    });
    window.setSize({
      width: screen.width / 2,
      height: halfHeight,
    });
  }
});

// Bottom left
Key.on("j", MOD, () => {
  const window = Window.focused();

  if (window) {
    window.setTopLeft({
      x: screen.x,
      y: screen.y + halfHeight,
    });
    window.setSize({
      width: screen.width / 2,
      height: halfHeight,
    });
  }
});

// Bottom right
Key.on("k", MOD, () => {
  const window = Window.focused();

  if (window) {
    window.setTopLeft({
      x: screen.x + screen.width / 2,
      y: screen.y + halfHeight,
    });
    window.setSize({
      width: screen.width / 2,
      height: halfHeight,
    });
  }
});

let info = new Key("å", MOD, () => {
  const windows = Space.active().windows();

  for (window of windows) {
    if (window.isVisible()) {
      windowFrame = window.frame();
      screen = Screen.main().flippedVisibleFrame();

      Modal.build({
        origin(modal) {
          return {
            x: windowFrame.x + windowFrame.width / 2 - modal.width / 2,
            y: screen.height - windowFrame.y - windowFrame.height / 2,
          };
        },
        weight: 16,
        duration: 2,
        appearance: "dark",
        icon: window.app().icon(),
        text: window.app().name(),
      }).show();
    }
  }
});
