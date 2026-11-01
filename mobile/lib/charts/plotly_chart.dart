import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Plotly.js chart rendered inside a WebView (required for SEA charts).
class PlotlyChart extends StatefulWidget {
  const PlotlyChart({
    super.key,
    required this.configJson,
    this.height = 320,
    this.zoomHint,
  });

  final String configJson;
  final double height;
  final String? zoomHint;

  @override
  State<PlotlyChart> createState() => _PlotlyChartState();
}

class _PlotlyChartState extends State<PlotlyChart> {
  late final WebViewController _controller;
  String? _lastConfig;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..enableZoom(true)
      ..setOnScrollPositionChange((_) {})
      ..loadHtmlString(_html(widget.configJson));
    _lastConfig = widget.configJson;
  }

  @override
  void didUpdateWidget(covariant PlotlyChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.configJson != _lastConfig) {
      _lastConfig = widget.configJson;
      _controller.runJavaScript('renderPlot(${widget.configJson});');
    }
  }

  String _html(String initialConfig) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
  <script src="https://cdn.plot.ly/plotly-2.35.2.min.js"></script>
  <style>
    html, body { margin: 0; padding: 0; background: transparent; overflow: hidden; touch-action: pan-x pan-y pinch-zoom; }
    #chart { width: 100%; height: ${widget.height.toInt()}px; }
  </style>
</head>
<body>
  <div id="chart"></div>
  <script>
    function renderPlot(cfg) {
      // Remove fixedrange so pinch/drag zoom works
      if (cfg.layout && cfg.layout.xaxis) delete cfg.layout.xaxis.fixedrange;
      if (cfg.layout && cfg.layout.yaxis) delete cfg.layout.yaxis.fixedrange;

      Plotly.react('chart', cfg.data, cfg.layout, {
        displayModeBar: false,
        responsive: true,
        scrollZoom: true,
        doubleClick: 'reset'
      });
    }
    renderPlot($initialConfig);
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          child: WebViewWidget(
            controller: _controller,
            gestureRecognizers: {
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
          ),
        ),
        if (widget.zoomHint != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              widget.zoomHint!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
      ],
    );
  }
}

class PlotlyConfigBuilder {
  static String lineChart({
    required List<Map<String, dynamic>> traces,
    required String yTitle,
    bool showLegend = true,
    double height = 320,
  }) {
    return jsonEncode({
      'data': traces,
      'layout': {
        'autosize': true,
        'height': height,
        'margin': {'l': 48, 'r': 12, 't': 8, 'b': 36},
        'paper_bgcolor': 'rgba(0,0,0,0)',
        'plot_bgcolor': 'rgba(0,0,0,0)',
        'hovermode': 'x unified',
        'showlegend': showLegend,
        'legend': {'orientation': 'h', 'x': 0, 'y': 1.12},
        'dragmode': 'zoom',
        'xaxis': {
          'showgrid': false,
          'tickfont': {'size': 11, 'color': '#6b7280'},
        },
        'yaxis': {
          'title': {'text': yTitle, 'font': {'size': 11, 'color': '#9ca3af'}},
          'gridcolor': '#f3f4f6',
          'tickfont': {'size': 11, 'color': '#6b7280'},
        },
      },
    });
  }

  static String boxChart({
    required List<Map<String, dynamic>> traces,
    required String yTitle,
    double height = 260,
  }) {
    return jsonEncode({
      'data': traces,
      'layout': {
        'autosize': true,
        'height': height,
        'margin': {'l': 48, 'r': 8, 't': 8, 'b': 32},
        'paper_bgcolor': 'rgba(0,0,0,0)',
        'plot_bgcolor': 'rgba(0,0,0,0)',
        'showlegend': false,
        'dragmode': 'zoom',
        'yaxis': {
          'title': {'text': yTitle, 'font': {'size': 11, 'color': '#9ca3af'}},
          'gridcolor': '#f3f4f6',
          'tickfont': {'size': 11, 'color': '#6b7280'},
        },
        'xaxis': {'tickfont': {'size': 12, 'color': '#374151'}},
      },
    });
  }

  static String stackedBar({
    required List<String> labels,
    required List<double> energy,
    required List<double> grid,
    required List<double> levies,
    required String yTitle,
  }) {
    return jsonEncode({
      'data': [
        {
          'x': labels,
          'y': energy,
          'type': 'bar',
          'name': 'Energy',
          'marker': {'color': '#0d9488'},
        },
        {
          'x': labels,
          'y': grid,
          'type': 'bar',
          'name': 'Grid',
          'marker': {'color': '#60a5fa'},
        },
        {
          'x': labels,
          'y': levies,
          'type': 'bar',
          'name': 'Levies',
          'marker': {'color': '#a78bfa'},
        },
      ],
      'layout': {
        'barmode': 'stack',
        'height': 220,
        'margin': {'l': 48, 'r': 8, 't': 8, 'b': 32},
        'paper_bgcolor': 'rgba(0,0,0,0)',
        'plot_bgcolor': 'rgba(0,0,0,0)',
        'yaxis': {'title': {'text': yTitle}},
        'showlegend': true,
        'legend': {'orientation': 'h'},
      },
    });
  }

  static Map<String, dynamic> splineTrace({
    required List<String> x,
    required List<double> y,
    required String name,
    required String color,
    bool fill = false,
  }) {
    return {
      'x': x,
      'y': y,
      'type': 'scatter',
      'mode': 'lines',
      'name': name,
      'line': {
        'shape': 'spline',
        'smoothing': 1.2,
        'color': color,
        'width': 2.5,
      },
      if (fill) 'fill': 'tozeroy',
      if (fill) 'fillcolor': '${color}22',
    };
  }

  static Map<String, dynamic> boxTrace({
    required List<double> y,
    required String name,
    required String color,
  }) {
    return {
      'y': y,
      'type': 'box',
      'name': name,
      'marker': {'color': color},
      'boxmean': 'sd',
    };
  }
}
