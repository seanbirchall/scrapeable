Shiny.addCustomMessageHandler("view", function(message) {
  Shiny.setInputValue('view', {object: message.obj, id: Date.now()})
});
