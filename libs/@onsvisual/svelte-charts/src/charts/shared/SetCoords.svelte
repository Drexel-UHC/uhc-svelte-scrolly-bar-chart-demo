<script>
  import { getContext } from 'svelte';
  import AccurateBeeswarm from '../../js/accurate-beeswarm';

  const {
    data,
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
    custom,
    width,
  } = getContext('LayerCake');

  let coords = $custom.coords;
  let type = $custom.type;
  let prevWidth = $width;
  let coord_needs_update = false;

  console.log(`coords: ${type}`);
  if (!$coords) {
    setCoords($custom.customData, $custom, $x, $y, $r, $width);
  }
  $: {
    console.log(' *********************** SetCoords ***********************');
    console.log(`$custom.groups_selected`);
    console.log($custom.groups_selected);
    console.log(`$coords`);
    console.log($coords);
    coord_needs_update = $coords.length
      ? $coords.length != $custom.groups_selected.length
      : false;
    console.log(`coord_needs_update: ${coord_needs_update}`);
  }

  $: {
    if (!coord_needs_update) {
      setCoords($data, $custom, $x, $y, $r, $width);
    }
  }
  // $: {
  //   if (coord_needs_update) {
  //     console.log('UPDATE setCoords()');
  //     setCoords($custom.customData, $custom, $x, $y, $r, $width);
  //   }
  // }
  function setCoords(data, custom, x, y, r, width) {
    let mode = custom.mode;
    let padding = custom.padding;
    let duration = custom.animation && width == prevWidth ? custom.duration : 0;

    prevWidth = width;

    let newcoords;
    console.log(`SetCoord.svelte: data`);
    console.log(data);
    newcoords = data.map((d, i) =>
      d.map((e, j) => {
        console.log(e);
        console.log(j);
        return {
          x:
            mode == 'grouped' && $xScale.bandwidth
              ? $xGet(e) + i * (1 / data.length) * $xScale.bandwidth()
              : mode == 'grouped'
              ? $xGet(e)[0] +
                i * (1 / data.length) * Math.max(0, $xGet(e)[1] - $xGet(e)[0])
              : $xScale.bandwidth
              ? $xGet(e)
              : $xGet(e)[0],
          y: y(e),
          w:
            mode == 'grouped' && $xScale.bandwidth
              ? $xScale.bandwidth() / data.length
              : mode == 'grouped'
              ? Math.max(0, $xGet(e)[1] - $xGet(e)[0]) / data.length
              : $xScale.bandwidth
              ? $xScale.bandwidth()
              : Math.max(0, $xGet(e)[1] - $xGet(e)[0]),
          h:
            mode == 'default' ||
            mode == 'grouped' ||
            ((mode == 'comparison' || mode == 'stacked') && i == 0)
              ? y(e)
              : mode == 'stacked'
              ? y(e) - y(data[i - 1][j])
              : 0,
        };
      })
    );

    coords.set(newcoords, { duration });
    console.log(`SetCoord.svelte: new coords`);
    console.log(newcoords);
  }
</script>
