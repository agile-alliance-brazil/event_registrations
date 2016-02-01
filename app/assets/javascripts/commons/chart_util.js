transformData = function(data) {
  var dataArray = data;

  var chartDataArray = [];
  $.each(dataArray, function(key, value){
    var chartData = { name: key, y: value };
    chartDataArray.push(chartData);
  });

  return chartDataArray;
};
