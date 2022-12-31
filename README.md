enlabel: quick start
================

### Introduction

R’s lackluster support for variable labels is often a source of
frustration, especially when working with survey data. This is because
survey data:

- often contains long labels (i.e. questions asked to respondents);
- comes from environments with native support for labels such as SPSS or
  STATA;
- *has to be frequently transformed from wide to long format* (this is
  particularly true of multiple choice questions).

`enlabel` addresses the last problem in particular - labeling variable
names transformed into values in a long format dataframe. Long format
data, especially in the tidyverse context, lends itself more easily to
certain kinds of analyses and visualisations. However, the output of
these transformations usually comprises (only) numbers and question
codes and can be difficult to read, interpret, and communicate.
`enlabel` provides you with the tools to quickly append meaningful,
human-readable descriptions to your data.

As a bonus, enlabel also provides one quality-of-life function for
labeling dataframe headers. This can be useful when you are planning to
export your data to a different format (e.g. to .xlsx using the `expss`
package).

### Labeling long format data

The example below presents a typical task when working with survey
data - selecting and summarising a group of variables sharing a common
prefix. The names of the pivoted variables (i.e. question codes) are
stored in the “name” column. The data comes from an unpublished study of
Polish makerspaces conducted in 2022. Codes in the name column represent
different kinds of tools and values in the proportion column the share
of makerspaces having a prarticular tool at their disposal.

``` r
library(enlabel)
library(ggplot2)
library(dplyr)
library(tidyr)


df <- haven::read_sav("makerspaces.sav")

tools_summary <- df %>%
  select(starts_with('HW')) %>%
  pivot_longer(everything()) %>%
  count(name, value) %>%
  group_by(name) %>%
  summarise(proportion = n / sum(n), value = value) %>%
  filter(value == "Y") %>% 
  select(-value)

head(tools_summary, 20)
#> # A tibble: 20 × 2
#> # Groups:   name [20]
#>    name       proportion
#>    <chr>           <dbl>
#>  1 HW01_SQ001     0.524 
#>  2 HW01_SQ002     0.262 
#>  3 HW01_SQ003     0.405 
#>  4 HW01_SQ004     0.0714
#>  5 HW01_SQ005     0.310 
#>  6 HW01_SQ006     0.143 
#>  7 HW01_SQ007     0.333 
#>  8 HW01_SQ008     0.476 
#>  9 HW01_SQ009     0.405 
#> 10 HW01_SQ010     0.595 
#> 11 HW01_SQ011     0.286 
#> 12 HW01_SQ012     0.738 
#> 13 HW01_SQ013     0.548 
#> 14 HW01_SQ014     0.643 
#> 15 HW01_SQ015     0.238 
#> 16 HW01_SQ016     0.262 
#> 17 HW01_SQ017     0.0476
#> 18 HW01_SQ018     0.167 
#> 19 HW01_SQ019     0.0238
#> 20 HW01_SQ020     0.0476
```

`enlabel` allows you to source the dataset for labels with
`extract_label_from_data()`. The function accepts as an argument either
a path to the .sav file or to an R dataframe with a `variable.labels`
attribute. Importing a .sav file with the `foreign` package or using the
“Export to R” functionality in LimeSurvey will both create such objects.
Unfortunately, this does not work with objects imported with the `haven`
package (this means that, in this particular case,
`extract_labels_from_data(df)` is not going to work).

If you are working with only one survey, there is no need to assign the
output of `extract_labels_from_data()` to a variable - it is stored in
cache.

``` r
extract_labels_from_data("makerspaces.sav")
```

``` r
tools_summary %>% append_labels() %>% head(20)
#> # A tibble: 20 × 3
#> # Groups:   name [20]
#>    name       proportion labels                                                 
#>    <chr>           <dbl> <chr>                                                  
#>  1 HW01_SQ001     0.524  [Drukarka 3D] Czy Pana/i pracownia dysponuje następują…
#>  2 HW01_SQ002     0.262  [Skaner 3D] Czy Pana/i pracownia dysponuje następujący…
#>  3 HW01_SQ003     0.405  [Ploter laserowy] Czy Pana/i pracownia dysponuje nastę…
#>  4 HW01_SQ004     0.0714 [Ploter tnący, nożowy] Czy Pana/i pracownia dysponuje …
#>  5 HW01_SQ005     0.310  [Ploter CNC (drewno, sklejka)] Czy Pana/i pracownia dy…
#>  6 HW01_SQ006     0.143  [Ploter CNC (metale)] Czy Pana/i pracownia dysponuje n…
#>  7 HW01_SQ007     0.333  [Frezarka lub tokarka CNC] Czy Pana/i pracownia dyspon…
#>  8 HW01_SQ008     0.476  [Komputer ze specjalistycznym oprogramowaniem do proje…
#>  9 HW01_SQ009     0.405  [Komputer ze specjalistycznym oprogramowaniem do proje…
#> 10 HW01_SQ010     0.595  [Narzędzia stolarskie] Czy Pana/i pracownia dysponuje …
#> 11 HW01_SQ011     0.286  [Narzędzia do pracy z tkaninami lub skórą] Czy Pana/i …
#> 12 HW01_SQ012     0.738  [Standardowe narzędzia do prac ręcznych (młotki, wiert…
#> 13 HW01_SQ013     0.548  [Zestaw elektroniki/programowania Arduino lub podobny]…
#> 14 HW01_SQ014     0.643  [Narzędzia do pracy z elektroniką (np. do lutowania, p…
#> 15 HW01_SQ015     0.238  [Narzędzia tokarskie (drewno lub metal)] Czy Pana/i pr…
#> 16 HW01_SQ016     0.262  [Narzędzia spawalniczo-ślusarskie] Czy Pana/i pracowni…
#> 17 HW01_SQ017     0.0476 [Narzędzia garncarskie do pracy z gliną] Czy Pana/i pr…
#> 18 HW01_SQ018     0.167  [Narzędzia do prac ciesielskich lub snycerskich (zaawa…
#> 19 HW01_SQ019     0.0238 [Maszyny sitodrukowe] Czy Pana/i pracownia dysponuje n…
#> 20 HW01_SQ020     0.0476 [Urządzenia lakiernicze lub malarnia techniczna] Czy P…
```

If you want to visualize the data, you might want to trim the length of
the labels which by default contain both the parent-question text as
well as the subquestion label. You can easily discard the
parent-question text by setting the `trim` argument to `TRUE`.

``` r
tools_summary %>% 
  append_labels(trim = TRUE) %>% 
  ggplot(aes(proportion, reorder(labels, proportion))) + 
  geom_col() +
  scale_y_discrete(labels = scales::label_wrap(40)) +
  theme_minimal() +
  theme(axis.title.y = element_blank())
```

![](README_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

By default, `append_labels()` searches for the codes in the “name”
column. It is designed to to fit into the dplyr select-and-pivot
pipeline without the need to specify any additional arguments.

### Sourcing labels from LimeSurvey

`enlabel` gives you the option of sourcing your labels directly from
LimeSurvey. To do this, you need to first connect to LimeSurvey
RemoteControl API. `enlabel` uses a modified version of the `limer`
package to establish connection.

The creators of `limer` no longer maintain it. An up-to-date version of
the package, compatible with the latest versions of LimeSurvey, can be
installed directly from my github
`devtools::install_github("wjk-g/limer")`.

``` r
connect2ls("your_username", "your_password", "url_to_ls_api")
extract_labels_from_ls(survey_id)
```

`append_labels()` behaves the same regardless of the source of your
labels. The only difference is that labels imported from LimeSurvey do
not include the parent-question text (the `trim` argument does not apply
to them).
