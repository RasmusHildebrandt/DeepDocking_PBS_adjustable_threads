# Adapted DeepDocking protocol for PBS-type HPC schedulers adjustable for the number of threads permissable with the users hardware configuration
This is an adaptation of the original DeepDocking protocol developed by Gentile et al. 2022 [1,2], made under the MIT license agreement.

This adapted protocol is made for automated fred-based DeepDocking on HPC' with PBS type schedulers. It builds on the orignal protocol, by automatically adjusting the computational resources requested to the optimal hardware configuration for the user. 

To setup this adapted protocol, the user should first setup a DeepDocking directory, within their home directory, containing the subdiretories as highlighted in figure 1. The user should then make a log.txt file containing the desired parameters for running DeepDocking along with information about the users HPC configuration. An example of this is shown in the log.txt file within this repository. 

![Alt text](workspace.png?raw=true "Title")
**Figure 1** Workspace to be set up for running the adapted DeepDockign protocol.

Once setup has been completed the following steps can be followed. These largely follow the same steps as the orignal DeepDocking protocol, so for elaboration on parameters/methodology refer to [2]:

**Stage 1: library processing**

1. Smiles were concatenated and then split into a number of files equal to themaximum
number of jobs possible for the configuration as specified in the log.txt file. This process
was automated using the script:
    ```
    $ qsub -v file_path="~/DeepDocking" optimize_max_jobs
    ```
2. Tautomers and isomers were generated in preparation of morgan fingerprint generation
by running the script:
    ```
    $ qsub -v file_path="~/DeepDocking" DD_protocl/utilities/compute_states.sh
    ```
3. 1024-bit Morgan fingerprints corresponding to each smile were generated running the
script:
    ```
    $ qsub -v file_path="~/DeepDocking" DD_protocol/utilities/compute_morgan_fp.sh
    ```
**Stage 2: Receptor preparation**

4. The Outward facing MsbA structure (PDB accession: 3B60) was opened in OpenEye
OeDOCKING 4.1.1.0 GUI (OpenEye Scientific Software 2021). The residues within ligand
binding site 8 (LB8), determined with the P2Rank ligand binding search, were selected.
A search box was centered at the predicted binding site, encompassing all involved
residues

5. Site shape potential was calculated using the balanced setting and no further constraints
were used.

6. The finalised open design unit was uploaded to the docking_grid directory as indicated
in Fig. 5

**Stage 3: Sampling for DD_model training**

7. The smile library was then sampled for model training by running the modified script:
    ```
    $ qsub -v iteration="1",cpus="20",project_dir="projects",project_name="protein_test_automated",mol="1000000"environment="dd-env" DD_protocol/phase_1.sh
    ```
    
**Stage 4: Ligand preparation for Fred Docking**

8. Smiles were converted to the .oeb.gz format as best suited for Fred docking using the
script:
    ```
    $ qsub -v iteration="1",project_dir="projects",project_name="protein_test_automated" DD_protocol/phase_2_fred.sh
    ```
**Stage 5: Fred docking**

9. Fred docking on the sampled molecules was carried out running the script:
    ```
    $ qsub -v iteration="1",project_dir="projects", project_name="protein_test_automated" DD_protocol/phase_3_fred.sh
    ```
**Stage 6: DD_model training/evaluation**

10. Model training depending on the iteration. In the first iteration, progressive evaluation is carried out to determine the optimal sampling size (a). In the following iterations, regular training is carried out on the specified optimal sample size 1b)
     
     a. Progressive evaluation was carried out out running the script:
     
    ```
     $ qsub -v eval\_l="Home_PathDeepDocking/projects",project_n="protein_test_automated",percent_fm="1",percent_lm="0.01",recall_v="0.90",max_s="1000000",min_s="250000",n_s="4",time="00-20:00",en="dd-env" DD_protocol/progressive_evaluation.sh
    ```
      
    b. Regular training was carried out running the modified script:
  
    ```
    $ qsub -v iteration="3",t_pos="3",eval_location="Home_Path/DeepDocking/projects",project_name="protein_test_automated",last_iteration="5",percent_first="1",percent_last="0.01",rec="0.90",time="00-20:00",env="dd-env" DD_protocol/phase_4.sh
    ```
    
**Stage 7: Model inference**

11. Using the best model from stage 6, predicted hits were infered by running the script:
    ```
    $ qsub -v iteration="5",eval_l="Home_Path/DeepDocking/projects",project_n="protein_test_automated",recall_v="0.90",en="dd-env" DD_protocol/phase_5.sh
    ```
**Stage 8 Successive iterations**

12. Step 7-11 were repeated, changing the iteration number accordingly till the the final desired iteration has been run

**Stage 9. Final extraction**

13. Having enriched the database to a number that was computationally feasible to dock with FRED (McGann 2011), SMILES and their virtual hit-likenesses were extracted by running the script:
    ```
    $ -v file_path="~/DeepDocking" optimize_max_jobs
    ```
**Stage 10: Final docking**

14. Final docking was carried out in the same manner as described in section 2.2, step 2-



**Awknoledgements**
This adapted protocol was created unter the terms of the MIT license agreement and full credits go toward Gentile et. al for developing the original protocol. This adapted protocol was made as part of a research project undertaken under supervision by Dr. Konstantinos Beis at the Beis Group at the Harwell Research Complex, Didcot, UK. 

**Referencing**

[1]Gentile, F. et al. Deep Docking: A Deep Learning Platform for Augmentation of Structure Based Drug Discovery. ACS Cent. Sci. 6, 939–949 (2020)__

[2}Gentile, F. et al. Artificial intelligence–enabled virtual screening of ultra-large chemical libraries with deep docking. Nat. Protoc. (2022)
