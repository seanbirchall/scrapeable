document.addEventListener("keydown", function(event) {
  if (event.ctrlKey && event.key === "i") {
    document.getElementById("editor-import").click();
  }
});

document.addEventListener("keydown", function(event) {
  if (event.ctrlKey && event.shiftKey && event.key === "Enter") {
    document.getElementById("editor-run").click();
  }
});
