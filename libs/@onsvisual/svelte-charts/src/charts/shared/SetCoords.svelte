<script>
  import { getContext } from 'svelte';
  import AccurateBeeswarm from '../../js/accurate-beeswarm';

  const {
    data,
    flatData,
    x,
    y,
    r,
    xGet,
    yGet,
    rGet,
    xScale,
    yScale,
    yRange,
    rRange,
    xDomain,
    yDomain,
    custom,
    width,
  } = getContext('LayerCake');

  let coords = $custom.coords;
  let type = $custom.type;
  let prevWidth = $width;

  $: setCoords($data, $custom, $x, $y, $r, $width, $custom.groups_select_array);

  function setCoords(
    original_data,
    custom,
    x,
    y,
    r,
    width,
    groups_select_array
  ) {
    let data = JSON.parse(JSON.stringify(original_data));
    custom.groups_select_array.map((d, i) => {
      if (d < 0) {
        data[i].map((x, ii) => {
          // console.log(`${i} ${ii}`);
          // console.log(data[i]);
          // data[i][ii].value = 0;
        });
      }
    });

    let mode = custom.mode;
    let padding = custom.padding;
    let duration = custom.animation && width == prevWidth ? custom.duration : 0;

    prevWidth = width;

    let newcoords;
    if (type == 'bar') {
      let xpos = [];
      let xneg = [];
      newcoords = data.map((d, i) => {
        return d.map((e, j) => {
          if (!xpos[j]) xpos[j] = 0;
          if (!xneg[j]) xneg[j] = 0;
          let x0 =
            mode == 'default' ||
            mode == 'grouped' ||
            (mode == 'comparison' && i == 0)
              ? $xDomain[0]
              : mode == 'stacked' && x(e) >= 0
              ? xpos[j]
              : mode == 'stacked'
              ? xneg[j]
              : x(e);
          let x1 =
            mode == 'default' ||
            mode == 'grouped' ||
            (mode == 'comparison' && i == 0)
              ? x(e)
              : mode == 'stacked' && x(e) >= 0
              ? xpos[j] + x(e)
              : mode == 'stacked'
              ? xneg[j] + x(e)
              : x(e);
          if (x(e) >= 0) {
            xpos[j] += x(e);
          } else {
            xneg[j] += x(e);
          }
          let y0 =
            mode == 'grouped'
              ? $yGet(e) + i * ($yScale.bandwidth() / data.length)
              : $yGet(e);
          let y1 =
            mode == 'grouped'
              ? y0 + $yScale.bandwidth() / data.length
              : y0 + $yScale.bandwidth();
          return { x0, x1, y0, y1 };
        });
      });
    } else if (type == 'column') {
      let ypos = [];
      let yneg = [];
      newcoords = data.map((d, i) => {
        // console.log(`column ${mode}: ${i}`);
        // console.log(d);

        return d.map((e, j) => {
          // console.log(`${i} ${j}`);
          // console.log(e);
          if (!ypos[j]) ypos[j] = 0;
          if (!yneg[j]) yneg[j] = 0;
          let x0 =
            mode == 'grouped' && $xScale.bandwidth
              ? $xGet(e) + i * (1 / data.length) * $xScale.bandwidth()
              : mode == 'grouped'
              ? $xGet(e)[0] +
                i * (1 / data.length) * Math.max(0, $xGet(e)[1] - $xGet(e)[0])
              : $xScale.bandwidth
              ? $xGet(e)
              : $xGet(e)[0];
          let x1 =
            mode == 'grouped' && $xScale.bandwidth
              ? x0 + $xScale.bandwidth() / data.length
              : mode == 'grouped'
              ? x0 + Math.max(0, $xGet(e)[1] - $xGet(e)[0]) / data.length
              : $xScale.bandwidth
              ? x0 + $xScale.bandwidth()
              : x0 + Math.max(0, $xGet(e)[1] - $xGet(e)[0]);
          let y0 =
            mode == 'default' ||
            mode == 'grouped' ||
            (mode == 'comparison' && i == 0)
              ? $yDomain[0]
              : mode == 'stacked' && y(e) >= 0
              ? ypos[j]
              : mode == 'stacked'
              ? yneg[j]
              : y(e);
          let y1 =
            mode == 'default' ||
            mode == 'grouped' ||
            (mode == 'comparison' && i == 0)
              ? y(e)
              : mode == 'stacked' && y(e) >= 0
              ? ypos[j] + y(e)
              : mode == 'stacked'
              ? yneg[j] + y(e)
              : y(e);
          if (y(e) >= 0) {
            ypos[j] += y(e);
          } else {
            yneg[j] += y(e);
          }
          let opacity = custom.groups_select_array[i] > -1 ? 1 : 0;
          return { x0, x1, y0, y1, opacity };
        });
      });
    } else if (type == 'scatter') {
      let rVal = (d) => (r ? $rGet(d) : $rRange[0]);
      newcoords = y
        ? data.map((d) => ({ x: x(d), y: y(d), r: rVal(d) }))
        : new AccurateBeeswarm(
            data,
            (d) => rVal(d),
            (d) => $xGet(d),
            padding,
            $yRange[0] / 2
          )
            .calculateYPositions()
            .map((d) => ({
              x: $xScale.invert(d.x),
              y: $yScale.invert(d.y),
              r: d.r,
            }));
    } else {
      newcoords = data.map((d) =>
        d.map((e) => {
          return {
            x: x(e),
            y: y(e),
          };
        })
      );
    }
    if (type == 'dotplot') {
      console.log(newcoords), 'dot plot';
    }
    console.log(`newcoords`);
    console.log(newcoords);

    coords.set(newcoords, { duration });
  }
</script>
