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

  import { groupedData } from './data/grouped_data.js';
  import { flatData } from './data/flat_data.js';

  console.log(`JSON IMPORTS`);
  console.log(groupedData);
  console.log(flatData);

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
  let title = 'Stacked';
  let mode = 'stacked';
  let groups_all = ['apples', 'bananas', 'cherries', 'dates'];
  let groups_selected = groups_all;

  let actions = {
    chart: {
      chart01: () => {
        step = 'chart01';
        title = 'Stacked';
        mode = 'stacked';
        groups_selected = groups_all;
      },
      chart02: () => {
        step = 'chart02';
        title = 'Barcode';
        mode = 'barcode';
        groups_selected = groups_all;
      },
      chart03: () => {
        step = 'chart03';
        title = 'Grouped Column chart';
        mode = 'grouped';
        groups_selected = groups_all;
      },
      chart04: () => {
        step = 'chart04';
        title = 'Grouped Column chart';
        mode = 'grouped';
        groups_selected = ['bananas', 'cherries'];
      },
    },
  };

  // # ============================================================================ #
  //   5.4 State

  // # ============================================================================ #
  //   5.5 Initialisation code (get data)

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
              {mode}
              {title}
              {hover}
              {hovered}
              on:hover={doHover}
              {select}
              {selected}
              on:select={doSelect}
              {animation}
              legend
              {groups_all}
              {groups_selected}
              {step}
            >
              <!-- <div slot="options" class="controls small">
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
              </div> -->
            </ColumnChart>
          {/if}
        </div>
      </div>
    </figure>
  </div>

  <div slot="foreground">
    <section data-id="chart01">
      <div class="col-medium">
        <p>This is a <strong>stacked</strong> column chart</p>
      </div>
    </section>
    <section data-id="chart02">
      <div class="col-medium">
        <p>This is a <strong>barcode</strong> chart.</p>
      </div>
    </section>
    <section data-id="chart03">
      <div class="col-medium">
        <p>This is a <strong>grouped</strong> bar chart</p>
      </div>
    </section>
    <section data-id="chart04">
      <div class="col-medium">
        <p>We can <strong>add/remove groups</strong> from the bar chart.</p>
      </div>
    </section>
  </div>
</Scroller>

<Divider />
<div class="stickDev">
  step: {step}
</div>

<!-- 
  # ============================================================================ #
  #  Conclusion
-->

<!-- 
  # ============================================================================ #
  #  ............... style ...............
-->
<style>
  .stickDev {
    position: fixed;
    bottom: 0;
    right: 0;
    background-color: white;
    padding: 10px;
  }
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
