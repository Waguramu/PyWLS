import logging
import subprocess
import json

from typing import List, Optional, Tuple


class MathematicaWFCalc:
    """
    A class implementing subprocess calls to a Wolfram Language Script
    to find wavefunction's coefficients for provided parameters.

    For the computations implementation check BenderWu_Borel_Script.wls file.
    Requires WolframScript framework, check the README.
    """

    def __init__(self, path: str):
        self.script_path: str = path
        self.params: List[str] = []
        self.json: Optional[dict] = None
        self.coeff: List[str] = []
        self.eq: Optional[str] = None

    def get_path(self) -> str:
        return self.script_path

    def get_params(self) -> List[str]:
        return self.params

    def get_json(self) -> Optional[dict]:
        return self.json

    def get_coeff(self) -> List[str]:
        return self.coeff

    def get_equation(self) -> Optional[str]:
        return self.eq

    def set_params(self, params: List[str]):
        self.params = params
        self.json = None
        self.coeff = []
        self.eq = None

    def run_wls(self, params: List[str] = None) -> Tuple[str, str]:
        """
        Initialises and runs a subprocess to call the WL Script.
        :param params: list of string parameters to initialise the WL Script.
                       Default parameters:
                       - Order of perturbation / BenderWu o=20
                       - Pade order / half-order of wavefunction p=3
                       - Max harmonics K=6
                       - Parameter G=0.1
        :return: Tuple[str, str]
        """
        # Running WSL script in a term
        self.params = params if params is not None and len(params) > 0 else self.params
        command = ["wolframscript", "-script", self.script_path] + self.params
        logging.info(f"Executing subprocess with command: {' '.join(command)}")
        try:
            process = subprocess.Popen(command, stdout=subprocess.PIPE)
            output, error = process.communicate()
            try:
                logging.info("Decoding outputs of the subprocess")
                output = output.decode() if output is not None else output
                error = error.decode() if error is not None else error
            except Exception as e:
                logging.error(f"Bytes decoding failed: {e}")
            self.json = self.parse(output)
            if self.json is not None:
                logging.info(f"Setting attributes for the keys: 'coeff' and 'eq'")
                self.coeff, self.eq = self.json['coeff'], self.json['eq']
        except Exception as e:
            output = ""
            error = str(e)
            logging.error(f"Subprocess failed: {e}")
        return output, error

    def parse(self, string: str) -> dict:
        jsn_string = string.split('\n')[-2]
        logging.info(f"Parsing JSON for WSL result: {jsn_string}")
        try:
            jsn = json.loads(jsn_string)
        except Exception as e:
            jsn = None
            logging.error(f"JSON parsing failed: {e}")
        return jsn


# Example
calc = MathematicaWFCalc(path="BenderWu_Borel_Script.wls")
calc.run_wls(params=["o=20", "p=3", "K=6", "G=0.1"])
print(calc.get_coeff())
