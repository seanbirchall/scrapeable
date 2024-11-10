Split(['#pane-code', '#pane-control'], {
  direction: 'horizontal',
  minSize: 200,
  gutterSize: 6
});

Split(['#pane-editor', '#pane-console'], {
  direction: 'vertical',
  minSize: 100,
  gutterSize: 6
});
