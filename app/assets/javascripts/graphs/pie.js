$(function () {
    var pieDiv = $('#pie_div');

    pieDiv.highcharts({
        chart: {
            type: 'pie',
            options3d: {
                enabled: true,
                alpha: 40,
                beta: 0
            }
        },
        title: {
            text: pieDiv.data('title')
        },
        subtitle: {
            text: 'Source: Agile Alliance Brazil'
        },
        tooltip: {
            pointFormat: '<b>{point.percentage:.1f}%</b>'
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: true,
                    format: '<b>{point.percentage:.1f} %</b>'
                },
                showInLegend: true
            }
        },
        series: [{
            name: 'Share',
            colorByPoint: true,
            data: pieDiv.data('share')
        }]
    });
});
