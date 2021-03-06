$(function(){
  // カテゴリーセレクトボックスのオプションを作成
  function appendOption(category){
    var html = `<option value="${category.id}" data-category="${category.id}">${category.name}</option>`;
    return html;
  }
  // 子カテゴリーの表示作成
  function appendChidrenBox(insertHTML){
    var childSelectHtml = '';
    childSelectHtml = `<div class='listing-select-wrapper__added' id= 'children_wrapper'>
                        <div class='listing-select-wrapper__box'>
                          <select class="listing-select-wrapper__box--select" id="child_category_edit" name="product[category_id]">
                            <option value="---" data-category="---">---</option>
                            ${insertHTML}
                          <select>
                          <i class='fas fa-chevron-down listing-select-wrapper__box--arrow-down'></i>
                        </div>
                      </div>`;
    $('.listing-product-detail__category').append(childSelectHtml);
  }
  // 孫カテゴリーの表示作成
  function appendGrandchidrenBox(insertHTML){
    var grandchildSelectHtml = '';
    grandchildSelectHtml = `<div class='listing-select-wrapper__added' id= 'grandchildren_wrapper'>
                              <div class='listing-select-wrapper__box'>
                                <select class="listing-select-wrapper__box--select" id="grandchild_category_edit" name="product[category_id]">
                                  <option value="---" data-category="---">---</option>
                                  ${insertHTML}
                                </select>
                                <i class='fas fa-chevron-down listing-select-wrapper__box--arrow-down'></i>
                              </div>
                            </div>`;
    $('.listing-product-detail__category').append(grandchildSelectHtml);
  }
  // 親カテゴリー選択後のイベント
  $('#parent_category_edit').on('change', function(){
    var parentCategory = document.getElementById('parent_category_edit').value; //選択された親カテゴリーの名前を取得
    $.ajax({
      url: '/get_category_children',
      type: 'GET',
      data: { parent_name: parentCategory },
      dataType: 'json'
    })
    .done(function(children){
      $('#children_wrapper').remove(); //親が変更された時、子以下を削除するする
      $('#grandchildren_wrapper').remove();
      var insertHTML = '';
      children.forEach(function(child){
        insertHTML += appendOption(child);
      });
      appendChidrenBox(insertHTML);
    })
    .fail(function(){
      alert('親カテゴリーを選択してください。');
      $('#children_wrapper').remove();
      $('#grandchildren_wrapper').remove();
    })
  });
  // 子カテゴリー選択後のイベント
  $('.listing-product-detail__category').on('change', '#child_category_edit', function(){
    var childId = $('#child_category_edit option:selected').data('category'); //選択された子カテゴリーのidを取得
    if (childId != "---"){ //子カテゴリーが初期値でないことを確認
      $.ajax({
        url: '/get_category_grandchildren',
        type: 'GET',
        data: { child_id: childId },
        dataType: 'json'
      })
      .done(function(grandchildren){
        if (grandchildren.length != 0) {
          $('#grandchildren_wrapper').remove(); //子が変更された時、孫以下を削除するする
          var insertHTML = '';
          grandchildren.forEach(function(grandchild){
            insertHTML += appendOption(grandchild);
          });
          appendGrandchidrenBox(insertHTML);
        }
      })
      .fail(function(){
        alert('親カテゴリーの選択からやり直してください');
        $('#children_wrapper').remove();
        $('#grandchildren_wrapper').remove();
      })
    }else{
      $('#grandchildren_wrapper').remove(); //子カテゴリーが初期値になった時、孫以下を削除する
    }
  });
})