var injectFileField = function() {
  var creative_image_upload_element = $('creative_image');
  var file_upload_element = new Element('input', {
    id: "creative_image",
    name: "creative[image]",
    size: "30",
    type: "file"
  })
  $('creative_image').set('text','');
  $('creative_image').adopt(file_upload_element);
}
