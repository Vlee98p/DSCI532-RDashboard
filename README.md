## Social Media Addiction Dashboard (Shiny for R)
An individual Shiny for R re-implementation of the DSCI 532 Group 30 Social Media Addiction Dashboard.

Deployed Dashboard: https://019cdf5e-7e7b-1eb4-ffa4-6af29201eba4.share.connect.posit.cloud

### Prerequisite
- RStudio with the following packages installed
```
rinstall.packages(c("shiny", "bslib", "dplyr", "plotly"))
```

### Run the App
1. Clone this repository and change directory to this project
```
git clone https://github.com/your-username/DSCI532-RDashboard.git
```
```
cd DSCI532-RDashboard
```

2. Open `app.R` in RStudio
3. click `Run App` or run in the R console
```
rshiny::runApp()
```

Note: The dataset is loaded directly from the [group30 project's public GitHub repository](https://github.com/UBC-MDS/DSCI-532_2026_30_social-media-addiction), so no local CSV file is needed to run this dashboard.
