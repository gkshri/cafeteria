products = []
productsIds = []
found = []
t = 0 ;

  jQuery(document).ready(function($){
    console.log("njnb")
    $("#order_notes").val("");

//handle listening to products images
  $("body").on('click' , '.allProducts' , (function (){
    productId = this.id;
    name = $("#name_"+this.id).text();
    price = Number(this.alt);
    if(productsIds.includes(productId)){
      $("#msg_"+this.id).text("*already added")
    }
    else{
      var product = {"id":productId,"price":price,"name":name}
      products.push(product);
      productsIds.push(productId);
        total = product['price'] ;
        $("#items").append(
          '<tr title="' + product['name'] + '" id="' + product['id'] + '" data-price="' + product['Price'] + '" class = "navbar navbar-brand">' +
          '<td>' + product['name'] + '|</td>' +
          '<td title="Unit Price">' + product['price'] + '</td>' +
          '<td title="Quantity"><input type="number" class="quantity" min="1" value=1 style="width: 30px;" id=' + product['id'] + '_q value=""/></td>' +
          '<td title="Total" id=' + product['id'] + '_t>$' + total + '</td>' +
          '<td title="Remove from Order" class="text-center" style="width: 40px;"><a href="javascript:void(0);" class="btn btn-xs btn-danger ' + "classProductRemove" + '">X</a></td>' +
          '</tr>'
        );
        total = product['price']*Number($("#"+product['id']+"_q").val());
        $("#"+product['id']+"_t").text(total);
        t += total ;
        $("#total").text(t);
    }
  }));

//calculate total for product and order
 $(document).on("input", ".quantity", function () {
  var id = this.id.split("_")[0];
  var price = Number($(this).closest("td").prev('td').text());
  var totalThis = this.value * price ;
  $("#"+id+"_t").text(totalThis) ;
  t += price ;
  $("#total").text(t);
    });

//handle X buttom
 $("body").on("click",".btn-danger",function(){
  this.closest("tr").remove();
  var i = productsIds.indexOf(this.closest("tr").id);
  products.splice(i,1);
  productsIds.splice(i,1);
  var totalThis = Number(this.closest("tr").children[2].children[0].value) * Number((this).closest("tr").children[1].innerText) ;
  t -= totalThis ;
  $("#total").text(t);
 })


 //Send order data to controller
 $("#save_order").click(function(event) {

 // stop form from submitting normally 
   event.preventDefault();
   console.log("stop")

  var order_products=[]
   $("#items").children().each(function(){
     product_id=Number(this.id)
     product_quantity=Number(this.children[2].children[0].value)
     order_products.push({"id":product_id,"quantity":product_quantity})
   });
   var user=""
   if($("#order_user_id").val() != null) 
    {
      user=$("#order_user_id").val() 
    }
  console.log(user)
  var finalOrder = {"notes": $("#order_notes").val() ,"room": $("#order_room").val(), "products":JSON.stringify(order_products),"usr":user}
  /* Send the data using post and put the results in a body */
    $.ajax({
      url: "/orders/new",
      type: "post",
      data: finalOrder,
      success: function(response) {
        $('body').html(response);
      },
      error:function(){
       //alert('Error');
      }
    });
});

OrdersIds = []
//handle listening to order in admin home/user order page
  $("body").on("click", ".order_tr", function(e) {
  console.log("===================================  ")
  var tr=$(this)
  var orid=this.id
  if(OrdersIds.includes(orid)){
    var divid="div_"+orid
    $('#'+divid).remove();
    var remove_prod_div = OrdersIds.indexOf(orid)
    OrdersIds.splice(remove_prod_div,1)
  }
  else{
    OrdersIds.push(orid);
    var oid={"oid":orid}
   $.ajax({
        url: "/orders/orderproductlist",
        type: "post",
        data: oid,
        success: function(response) {
          var pdata=response
          var total=0;
          var divs='<tr id=div_'+orid+'>'
          for(var i=0;i<pdata.length; i++)
          {
            divs+=
                 "<td>"+pdata[i].pprice+"LE<img src="+pdata[i].pimg+">"+pdata[i].pname+"  "+pdata[i].quantity+"piece/s</td>"
            total+=pdata[i].pprice*pdata[i].quantity
           }
           divs+='<td> Total ='+total+'</td></tr>';
           console.log(divs)
           tr.after(divs)
          },
        error:function(){
          console.log(e);
         //alert('Error');
        }
       });
  }
  console.log(OrdersIds)
});

myOrderTotal = 0
//calculating orders total amount
$('.amount').each(function(){
  myOrderTotal += Number(this.id);
})
$("#myOrderTotal").html(myOrderTotal);

//search bar
  $("#search").keyup(function(){
    $(".products_span").hide();
    itemSearch = $(this).val().toLowerCase()
    $(".name").each(function(){
      productName = this.innerText.toLowerCase()
      if(itemSearch == productName){
        $("#"+this.id.split("_")[1]+"_span").show();
      }
    })
        //show products if search bar has no value
    if($("#search").val() == "")
      $(".products_span").show();  
 });


//handle listening to user in admin checks page
userIds = []
$(".user_order_tr").click(function(e) {
  console.log("=======user_o=======")
  var tr=$(this)
  var uid=this.id
  if(userIds.includes(uid)){
    var divid="odiv_"+uid
    $('#'+divid).remove();
    var remove_order_div = userIds.indexOf(uid)
    userIds.splice(remove_order_div,1)
  }
  else{
    userIds.push(uid);
    var usid={"usid":uid}
   $.ajax({
      url: "/orders/userorderlist",
      type: "post",
      data: usid,
      success: function(response) {
       var pdata=response
       var divs='<table class="table nav navbar" id=odiv_'+uid+'><th> Order Date </th> <th>Amount</th>'
       for(var i=0;i<pdata.length; i++)
       {
        console.log(pdata[i].oid,pdata[i].odate,pdata[i].amount)
        divs+='<tr id='+pdata[i].oid+ ' class="order_tr">'+
        '<td>'+ pdata[i].odate +'</td>'+
        '<td>'+ pdata[i].amount +'</td>'
       }

      divs+='</table>'
       tr.after (divs)
        },
      error:function(){
        console.log(e);
       //alert('Error');
      }

   });
 }


});




});
