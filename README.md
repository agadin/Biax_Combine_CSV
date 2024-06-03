# Overview
`combineCSVs.m` is a MATLAB script that is used to combine multiple `.csv` files from the biax (or any time seperated row data) into one `.csv` file.

## Usage
The first step is to run the MATLAB file. There is an optional input variable of a an integer value between `0` and `100` taht will specify how much the data should be downsampled (1 is no downsampling; 0 is a 100% downsample). After running the script, it will prompt the user to specify if they want to select the `.csv` files from indvidual `Files` or from a `Folder` by selecting the respective options. If the `Files` option is selected a File Explorer window will open and the user can select multiple `.csv` files they want combined and hit `Open` when they are done. If the user selects `Folder` a File Explorer window will open and prompt the user to select a folder. All `.csv` files in this folder will be automatically openned. 

<img src="https://github.com/agadin/Biax_Combine_CSV/raw/main/demo_images/slider_demo.gif" alt="Slider Demo" width="400">

After defining the files to be combined, a UI slider window will appear to allow the user to select teh degree to which the data should be down sampled. A sample UI can be seen below:

The downsampling is defined as a percentage where **100%** is no downsampling and **0%** is complete downsampling. For example **70%** would remove 30% of the rows and keep 70%. The down sampling is defined by the following function (in case specific modifcation to downsampling is desired):

```
    downsampleRatio = round(downsampleRatio) / 100;
    if downsampleRatio < 1
        numRows = size(sortedData, 1);
        indices = round(linspace(1, numRows, round(numRows * downsampleRatio)));
        sortedData = sortedData(indices, :);
    end
```
Next the script will prompt the user to approve the automatic naming of the output file (`Use Base Filename` option) or to `Specify Manually`. `Use Base Filename` option will open a File Explorer window for the user to choose where teh combined output `.csv` is saved. If `Specify Manually` is chosen, a File Explorer window will open and the user can mannual modify the file name and file save location.
