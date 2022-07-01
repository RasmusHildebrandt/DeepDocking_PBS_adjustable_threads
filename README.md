# Adapted DeepDocking protocol for PBS-type HPC schedulers adjustable for the number of threads permissable with the users hardware configuration
This is an adaptation of the original DeepDocking protocol developed by Gentile et al. 2022 [1,2], made under the MIT license agreement.

This adapted protocol is made for automated fred-based DeepDocking on HPCs with PBS type schedulers. It builds on the orignal protocol, by automatically adjusting the computational resources requested to the optimal hardware configuration for the user. Still being under development, future versions will include SLURM configurations in addition to the ability to use GLIDE for docking.

To setup this adapted protocol, first you will have to create a DeepDocking directory, within their home directory, containing the subdiretories as highlighted in figure 1. The user should then make a log.txt file containing the desired parameters for running DeepDocking along with information about the users HPC configuration. An example of this is shown in the log.txt file within this repository. 

![Alt text](workspace.png?raw=true "Title")
**Figure 1** Workspace to be set up for running the adapted DeepDocking protocol. Here shown with an example for docking of MsbA

Once setup has been completed the following steps can be followed. These largely follow the same steps as the orignal DeepDocking protocol, so for elaboration on parameters/methodology refer to [2]:

**Stage 1: library processing**

1. Smiles should be concatenated and then split into a number of files equal to the maximum
number of array jobs possible for the configuration as specified in the log.txt file. This process
can be  automated using the script:
    ```
    $ qsub -v file_path="~/DeepDocking" DD_protocol/utilities/optimize.sh
    ```
2. Tautomers and isomers are generated in preparation of morgan fingerprint generation
by running the script:
    ```
    $ qsub -v file_path="~/DeepDocking" DD_protocl/utilities/compute_states.sh
    ```
3. 1024-bit Morgan fingerprints corresponding to each smile were are generated running the
script:
    ```
    $ qsub -v file_path="~/DeepDocking" DD_protocol/utilities/compute_morgan_fp.sh
    ```
**Stage 2: Receptor preparation**

4. Prepare the receptor with the OeDOCKING applications GUI, creating a OEDesignUnit at the site of interest.

5. The finalised OEDesignUnit should then be uploaded to the docking_grid directory as indicated
in Figure 1.

**Stage 3: Sampling for DD_model training**

6. The smile library should then be sampled for model training by running the modified script:
    ```
    $ qsub -v iteration="1",file_path="~/DeepDocking",project_name="protein_test_automated",mol="1000000" DD_protocol/phase_1.sh
    ```
    
**Stage 4: Ligand preparation for Fred Docking**

7. Smiles are to be converted to the .oeb.gz format as best suited for Fred docking. This is achieved by running the
script:
    ```
    $ qsub -v iteration="1",t_node="1",file_path="~/DeepDocking",project_name="protein_test_automated" DD_protocol/phase_2_fred.sh
    ```
**Stage 5: Fred docking**

8. Fred docking on the sampled molecules can then carried out running the script:
    ```
    $ qsub -v iteration="1",project_dir="projects",file_path="~/DeepDocking",project_name="protein_test_automated" DD_protocol/phase_3_fred.sh
    ```
**Stage 6: DD_model training/evaluation**

9. Model training depending on the iteration. In the first iteration, progressive evaluation is carried out to determine the optimal sampling size (a). In the following iterations, regular training is carried out on the specified optimal sample size (b)
     
     a. Progressive evaluation can be carried out running the script:
     
    ```
     $ qsub -l select=1:ncpus=4:mem=24gb:ngpus=1:gpu_type=RTX6000 -v file_path="~/DeepDocking",percent_fm="1",percent_lm="0.01",recall_v="0.90",max_s="1000000",min_s="250000",n_s="4",time="00-20:00",en="dd-env" DD_protocol/progressive_evaluation.sh
    ```
      
    b. Regular training can be carried out by running the modified script:
  
    ```
    $ qsub -v iteration="1",t_pos="3",file_path="~/DeepDocking",project_name="protein_test_automated",last_iteration="5",percent_first="1",percent_last="0.01",rec="0.90",time="00-20:00" DD_protocol/phase_4.sh
    ```
    
**Stage 7: Model inference**

10. Using the best model from stage 6, predicted hits are infered by running the script:
    ```
    $ qsub -v iteration="1",file_path="~/DeepDocking",project_n="protein_test_automated",recall_v="0.90" DD_protocol/phase_5.sh
    ```
**Stage 8 Successive iterations**

11. Step 6-10 should then berepeated, changing the iteration number accordingly till the the final desired iterations has been run.

**Stage 9. Final extraction**

12. Having enriched the database to a number that is computationally feasible to dock with FRED, SMILES and their virtual hit-likenesses can be extracted by running the script:
    ```
    $ qsub -v file_path="~/DeepDocking" DD_protocol/utilities/final_extraction.sh
    ```
**Stage 10: Final docking**

13. Final docking can then be carried out using the standard FRED procedure.



**Awknoledgements**
This adapted protocol was created under the terms of the MIT license agreement using the DeepDocking protocol by  Gentile et al. [2] 
This protocol was furthermore made as part of a research project undertaken under supervision by Dr. Konstantinos Beis at the Beis Group at the Harwell Research Complex, Didcot, UK. 


**References**

[1]Gentile, F. et al. Deep Docking: A Deep Learning Platform for Augmentation of Structure Based Drug Discovery. ACS Cent. Sci. 6, 939–949 (2020)__

[2}Gentile, F. et al. Artificial intelligence–enabled virtual screening of ultra-large chemical libraries with deep docking. Nat. Protoc. (2022)
