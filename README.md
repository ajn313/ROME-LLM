# Recurrent Optimization via Machine Editing: ROME
The ROME tool automates hardware design with minimal human input. A large language model (LLM) is utilized to generate and fix errors in code within a multi-stage design pipeline.

![ROME-flowchart](https://github.com/ajn313/ROME-LLM/blob/main/supplements/flowchart.png)

We provide a [Colab notebook](https://github.com/ajn313/ROME-LLM/blob/main/ROME_demo.ipynb) which implements the tool. GPT-4 is used by default which will require an OpenAI API Key, but instructions to modify this will be provided.

The necessary inputs include the names of a series of simpler submodules which can be built up into a more complex target modules, as well as unit testbenches for each submodule. We include testbenches for a few hierarchical arcitectures, and more will continue to be added. 

GitHub still under construction. 

## Citation
### Paper on arXiv:
[Link](https://arxiv.org/abs/2407.18276)
### BibTeX:
```
@misc{nakkab2024romebuiltsinglestep,
      title={Rome was Not Built in a Single Step: Hierarchical Prompting for LLM-based Chip Design}, 
      author={Andre Nakkab and Sai Qian Zhang and Ramesh Karri and Siddharth Garg},
      year={2024},
      eprint={2407.18276},
      archivePrefix={arXiv},
      primaryClass={cs.AR},
      url={https://arxiv.org/abs/2407.18276}, 
}
```
