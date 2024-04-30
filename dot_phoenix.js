const modifier = ["command", "option", "control", "shift"];

// right half
Key.on("right", modifier, () => {
  const screen = Screen.main().flippedVisibleFrame();
  const window = Window.focused();

  if (window) {
    window.setTopLeft({
      x: screen.x + screen.width / 2,
      y: screen.y,
    });
    window.setSize({
      width: screen.width / 2,
      height: screen.height,
    });
  }
});

// left half
Key.on("left", modifier, () => {
  const screen = Screen.main().flippedVisibleFrame();
  const window = Window.focused();

  if (window) {
    window.setTopLeft({
      x: screen.x,
      y: screen.y,
    });
    window.setSize({
      width: screen.width / 2,
      height: screen.height,
    });
  }
});

// top right
Key.on("i", modifier, () => {
  const screen = Screen.main().flippedVisibleFrame();
  const window = Window.focused();

  if (window) {
    window.setTopLeft({
      x: screen.x + screen.width / 2,
      y: screen.y,
    });
    window.setSize({
      width: screen.width / 2,
      height: screen.height / 2,
    });
  }
});
// Top left
Key.on("u", modifier, () => {
  const screen = Screen.main().flippedVisibleFrame();
  const window = Window.focused();

  if (window) {
    window.setTopLeft({
      x: screen.x,
      y: screen.y,
    });
    window.setSize({
      width: screen.width / 2,
      height: screen.height / 2,
    });
  }
});

// Bottom left
Key.on("j", modifier, () => {
  const screen = Screen.main().flippedVisibleFrame();
  const window = Window.focused();

  if (window) {
    window.setTopLeft({
      x: screen.x,
      y: screen.y + screen.height / 2,
    });
    window.setSize({
      width: screen.width / 2,
      height: screen.height / 2,
    });
  }
});

// Bottom right
Key.on("k", modifier, () => {
  const screen = Screen.main().flippedVisibleFrame();
  const window = Window.focused();

  if (window) {
    window.setTopLeft({
      x: screen.x + screen.width / 2,
      y: screen.y + screen.height / 2,
    });
    window.setSize({
      width: screen.width / 2,
      height: screen.height / 2,
    });
  }
});
