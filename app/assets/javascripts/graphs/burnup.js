$(function () {
    var burnupDiv = $('#burnup_div');

    burnupDiv.highcharts({
        chart: {
            type: 'spline',
            zoomType: 'x'
        },
        title: {
            text: 'Registrations Burn-up'

        },
        subtitle: {
            text: 'Source: https://inscricoes.agilebrazil.com/'
        },
        xAxis: {
            type: 'datetime',
            dateTimeLabelFormats: {
                month: '%e. %b %y',
                year: '%b %y'
            },
            title: {
                text: 'Date'
            }
        },
        yAxis: {
            title: {
                text: 'Registrations'
            }
        },
        legend: {
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'middle',
            borderWidth: 0
        },
        series: [{
            name: 'Ideal',
            data: burnupDiv.data('ideal')
        }, {
            name: 'Actual',
            data: burnupDiv.data('actual')
        }]
    });
});
