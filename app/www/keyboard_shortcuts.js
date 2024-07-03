document.addEventListener("keydown", function(event) {
  if(event.ctrlKey && event.key === "i"){
    event.preventDefault();
    document.getElementById("editor-import").click();
  }
  if(event.ctrlKey && event.shiftKey && event.key === "Enter"){
    event.preventDefault();
    document.getElementById("editor-run").click();
  }
  //if(event.ctrlKey && event.key === "s"){
  //  event.preventDefault();
  //  document.getElementById("share").click();
  //}
});


