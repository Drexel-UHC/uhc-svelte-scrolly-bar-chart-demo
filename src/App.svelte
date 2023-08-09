<!-- 
  # ============================================================================ #
  #  ............... script ...............
-->

<script>
  // # ============================================================================ #
  // 1. Core imports
  import { setContext, onMount } from 'svelte';
  import { getMotion } from './utils.js';
  import { themes } from './config.js';
  import UHCHeader from './layout/UHCHeader.svelte';
  import UHCFooter from './layout/UHCFooter.svelte';
  import Header from './layout/Header.svelte';
  import Section from './layout/Section.svelte';
  import Media from './layout/Media.svelte';
  import Scroller from './layout/Scroller.svelte';
  import Filler from './layout/Filler.svelte';
  import Divider from './layout/Divider.svelte';
  import Toggle from './ui/Toggle.svelte';
  import Arrow from './ui/Arrow.svelte';

  // # ============================================================================ #
  // 2. Project sepecific imports
  import { getData, setColors, getBreaks, getColor } from './utils.js';
  import { colors } from './config.js';
  import { BarChart, ColumnChart } from '../libs/@onsvisual/svelte-charts';

  // # ============================================================================ #
  // 3. Core config
  // Set theme globally (options are 'light', 'dark' or 'lightblue')
  let theme = 'light';
  setContext('theme', theme);
  setColors(themes, theme);

  // # ============================================================================ #
  // 4. Scroller Configs
  //  - These dont change much between projects.
  //// Config
  const threshold = 0.65;

  //// State
  let animation = true;
  let hover = true;
  let hovered = null;
  let hoveredScatter = null;
  let select = true;
  let selected = null;
  let selectedScatter = null;
  let barchart1 = {
    options: ['apples', 'bananas', 'cherries', 'dates'],
    selected: 'apples',
  };
  let barchart2 = {
    options: ['stacked', 'comparison', 'barcode', 'grouped'],
    selected: 'stacked',
  };
  let id = {}; // Object to hold visible section IDs of Scroller components
  let idPrev = {}; // Object to keep track of previous IDs, to compare for changes
  onMount(() => {
    idPrev = { ...id };
  });

  // Scroll Updater
  function runActions(codes = []) {
    //// Code to run Scroller actions when new caption IDs come into view
    codes.forEach((code) => {
      if (id[code] != idPrev[code]) {
        // if caption id changes then run then run following code to update chart
        if (actions[code][id[code]]) {
          actions[code][id[code]]();
        }
        idPrev[code] = id[code];
        step = id[code];
      }
    });
  }
  $: {
    // Run above code when 'id' object changes
    if (id) {
      runActions(Object.keys(actions));
    }
  }
  // # ============================================================================ #
  // 5. Project Configs
  // THese will change across projects

  // # ============================================================================ #
  //   5.1 Scrolly actions *********
  let step = 'chart01';
  let actions = {
    chart: {
      chart01: () => {},
    },
  };

  // # ============================================================================ #
  //   5.4 State

  // # ============================================================================ #
  //   5.5 Initialisation code (get data)
  let groupedData;
  let flatData;
  getData(`./data/fruits_grouped_data.csv`).then((arr) => {
    groupedData = arr;
    console.log('groupedData');
    console.log(arr);
  });
  getData(`./data/fruits_flat_data.csv`).then((arr) => {
    flatData = arr;
    console.log('flatData');
    console.log(arr);
  });
  const doHover = (e) => (hovered = e.detail.id);
  const doSelect = (e) => (selected = e.detail.id);
  const doHoverScatter = (e) => (hoveredScatter = e.detail.id);
  const doSelectScatter = (e) => (selectedScatter = e.detail.id);
</script>

<!-- 
  # ============================================================================ #
  #  ............... markup ...............
-->

<Divider />

<!-- 
  # ============================================================================ #
  #  Scrolly 1 ******************
-->

<Scroller {threshold} bind:id={id['chart']} splitscreen={true}>
  <div slot="background">
    <figure>
      <div class="col-wide height-full">
        <div class="chart">
          {#if flatData && groupedData && id}
            <ColumnChart
              {flatData}
              {groupedData}
              xKey="year"
              yKey="value"
              zKey="group"
              mode={barchart2.selected}
              title="Stacked / comparative column chart"
              {hover}
              {hovered}
              on:hover={doHover}
              {select}
              {selected}
              on:select={doSelect}
              {animation}
              legend
            >
              <div slot="options" class="controls small">
                {#each barchart2.options as option}
                  <label
                    ><input
                      type="radio"
                      bind:group={barchart2.selected}
                      value={option}
                    />
                    {option}</label
                  >
                {/each}
              </div>
            </ColumnChart>
          {/if}
        </div>
      </div>
    </figure>
  </div>

  <div slot="foreground">
    <section data-id="chart01">
      <div class="col-medium">
        <p>
          Trend of the cost of <strong>some fruits</strong> over time.
        </p>
      </div>
    </section>
  </div>
</Scroller>

<Divider />

<!-- 
  # ============================================================================ #
  #  Conclusion
-->

<!-- 
  # ============================================================================ #
  #  ............... style ...............
-->
<style>
  /* Styles specific to elements within the demo */
  :global(svelte-scroller-foreground) {
    pointer-events: none !important;
  }
  :global(svelte-scroller-foreground section div) {
    pointer-events: all !important;
  }
  select {
    max-width: 350px;
  }
  .stickDev {
    position: fixed;
    bottom: 0;
    right: 0;
    background-color: white;
    padding: 10px;
  }
  .chart {
    margin-top: 45px;
    width: calc(100% - 5px);
  }
  .chart-full {
    margin: 0 20px;
  }
  .chart-sml {
    font-size: 0.85em;
  }
  /* The properties below make the media DIVs grey, for visual purposes in demo */
  .media {
    background-color: #f0f0f0;
    display: -webkit-box;
    display: -ms-flexbox;
    display: flex;
    -webkit-box-orient: vertical;
    -webkit-box-direction: normal;
    -ms-flex-flow: column;
    flex-flow: column;
    -webkit-box-pack: center;
    -ms-flex-pack: center;
    justify-content: center;
    text-align: center;
    color: #aaa;
  }
</style>
