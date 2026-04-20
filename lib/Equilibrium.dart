import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'Code.dart';
import 'global.dart';
import 'Transport.dart';


class Equilibrium extends StatefulWidget {
  const Equilibrium({super.key});
  @override
  _EquilibriumState createState() => _EquilibriumState();
}

class _EquilibriumState extends State<Equilibrium> {
  final _phiController = TextEditingController();
  final _TfuelController = TextEditingController();
  final _TairController = TextEditingController();
  final _prController = TextEditingController();
  final _RHController = TextEditingController();
  final _TspecController=TextEditingController();
/*  final _formKey = GlobalKey<FormState>();
  final _yrController = TextEditingController();
  final _mnController = TextEditingController();
  final _dyController = TextEditingController();
  final _hrController = TextEditingController();
  final _minController = TextEditingController();
*/
  double phi = 1.0; double T_fuel = 298.15; double T_air = 298.15; 
  double P = 1.0; double RH = 0.0; double _AirToFuel = 0.0; 
  double _AdiabaticFlameTemp = 0.0; double _Moles = 0.0; double T_specified = 0.0;
  Fuel _selectedFuel=fuelDatabase[0]; // ✅ holds currently selected location
  
  // Variables to store calculation results
List<String> prod1 = new List.filled(18,'');
List<String> prod2 = new List.filled(18,'');
String AFT = ''; // Adiabatic Flame Temperature
String _sonic = '';
String _cp = '';
String _visc = '';
String _cond = '';
String _rho = '';
String _m_wt = '';
String _heat = '';
String totMoles = '';
String AtoF = " ";
String Fuel_Hf = " ";
String _phiinit =" ";
String _tfuelinit=" ";
String _tairinit=" ";
String _prinit=" ";
String _rhinit=" ";
String _tspecinit=' ';
bool _tActive = false; // de-activate controller box for specified temp


  @override
  void initState() {
    super.initState();
    phi = 1.0;
    T_fuel = 298.15;
    T_air = 298.15;
    RH = 0.0;
    _phiController.text = phi.toString();
    _TfuelController.text = T_fuel.toString();
    _TairController.text = T_air.toString();
    _prController.text = P.toString();
    _RHController.text = RH.toString();   // relative humidity
    _TspecController.text='  '; // specified temp controller
    _tspecinit = 'T_Prod ? K';
    _phiinit = 'phi '; _tfuelinit='T-fuel K'; 
    _prinit = 'P (atm)'; _tairinit = 'T-air K'; _rhinit = 'air R.H. %';
      _routine();
  } 
  
  void _getdata(){
    
    phi = double.tryParse(_phiController.text) ?? 0 ;
    T_fuel = double.tryParse(_TfuelController.text) ?? 0;
    T_air = double.tryParse(_TairController.text) ?? 0;
    P = double.tryParse(_prController.text) ?? 0;
    RH = double.tryParse(_RHController.text) ?? 0;
    if(_tActive==true){
      T_specified = double.tryParse(_TspecController.text) ?? 0.0;
      if(T_specified < 275.0 || T_specified > 5000.0) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:Text("T_Specified must be between 275 & 5000 ")),
        );
      }

    } else {
      T_specified = 0.0;
      _TspecController.text='  '; // specified temp controller
    }
     _routine();  
  }      // end of getdata

void _closeApp(){
  if(Platform.isAndroid){
    SystemNavigator.pop();    // android exit
  } else if(Platform.isIOS)  {
    exit(0);
  }
}

// BUIL UI 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.greenAccent, // background color for the title box
              borderRadius: BorderRadius.circular(8), // rounded corners
            ),
            child: const Text(
              'نواتج الاحتراق ودرجةالحرارة - اعداد د. محمود خالد',
              style: TextStyle(
                color: Colors.black, // text color
                fontSize: 12, fontWeight: FontWeight.bold,
              ),
            ),
          ),
          centerTitle: true, // optional
          backgroundColor: Colors.blue, // color of the AppBar itself
        

      ),

       body: SingleChildScrollView(
        child: Padding(
         padding: const EdgeInsets.all(2.0),         
            child: Column(
             children: [

      SwitchListTile(
        title: const Text("    Control Temperature at T_Prod ??",
          style: TextStyle(fontSize:12, fontWeight:FontWeight.bold )
        ),
        value: _tActive,
        // Moves the switch to the start (left) or end (right)
        controlAffinity: ListTileControlAffinity.trailing, 
        contentPadding: const EdgeInsets.symmetric(horizontal: 30.0), // Tightens the whole tile
        onChanged: (value) => setState(() => _tActive = value),
      ),






               Text(' Reactants Conditions', 
                style: TextStyle(fontSize:12, fontWeight:FontWeight.bold )
               ),
                SizedBox(height: 1),
                  Row(
                    children: [
                        //_buildInputField(_phiinit, _phiController, 80.0),
                        Expanded(child: _buildInputField(_phiinit, _phiController, true)),
                        SizedBox(width: 1),
                        Expanded(child: _buildInputField(_tfuelinit, _TfuelController,true)),
                        SizedBox(width: 1),
                        Expanded(child: _buildInputField(_tairinit, _TairController,true)),
                        SizedBox(width: 1),
                        Expanded(child: _buildInputField(_tspecinit, _TspecController,_tActive)),//                        Expanded(child: _buildInputField(_prinit, _prController,50.0)),
//                        SizedBox(width: 1),
//                        Expanded(child: _buildInputField(_rhinit, _RHController,50.0)),
//                        SizedBox(width: 1),
//                        Expanded(child: buildFuelSelector()),
                    ],
                  ),  // end of date input rows
                  Row(
                    children: [
                        //_buildInputField(_phiinit, _phiController, 80.0),
                        Expanded(child: _buildInputField(_prinit, _prController,true)),
                        SizedBox(width: 1),
                        Expanded(child: _buildInputField(_rhinit, _RHController,true)),
                        SizedBox(width: 1),
                        Expanded(child: buildFuelSelector()),
                    ],
                  ),  // end of date input rows


                //SizedBox(height: 3),
                  Row( 
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: _getdata,
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.teal),
                          minimumSize: MaterialStateProperty.all<Size>(const Size(20,25)),
                          ),
                        child: Text("احسب", 
                              style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                      ), 
                      SizedBox(width:1),
                      _outputBox('A/F '+AtoF),
                      SizedBox(width:1),
                      _outputBox('Flm T '+AFT+ ' K'),
                      SizedBox(width:1),
                      _outputBox('M '+_m_wt+' g/mol'),
                    ],
                    ), 

                  Row( 
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _outputBox('rho '+_rho+' kg/m3'),
                      SizedBox(width:1),
                      _outputBox('visc '+_visc+' Pa.s'),
                      SizedBox(width:1),
                      _outputBox('k '+_cond+' W/m.K'),
 
                    ],
                    ), 
                  
                  Row( 
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _outputBox('Cp '+_cp+' kJ/kg.K'),
                      SizedBox(width:1),
                      _outputBox('sonic vel '+_sonic+' m/s'),
                    ],
                    ), 
                  
                  Row( 
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width:1),
                      _outputBox('Q out '+_heat+' kJ/kg-fuel'),
                    ],
                    ), 



             Row(        // Main Central row encompassing two columns
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                        children: [
                         SizedBox(height: 3),
                          _prodlist(text1:' Product', text2:'Mol fraction', fill:Colors.blue.shade200),
                          _prodlist(text1:prod1[0], text2:prod2[0],fill:Colors.white),
                          _prodlist(text1:prod1[1], text2:prod2[1],fill:Colors.white),
                          _prodlist(text1:prod1[2], text2:prod2[2],fill:Colors.white),
                          _prodlist(text1:prod1[3], text2:prod2[3],fill:Colors.white),
                          _prodlist(text1:prod1[4], text2:prod2[4],fill:Colors.white),
                          _prodlist(text1:prod1[5], text2:prod2[5],fill:Colors.white),
                          _prodlist(text1:prod1[6], text2:prod2[6],fill:Colors.white),
                          _prodlist(text1:prod1[7], text2:prod2[7],fill:Colors.white),
                          _prodlist(text1:prod1[8], text2:prod2[8],fill:Colors.white),                         
/*                          _prodlist(text1:prod1[9], text2:prod2[9],fill:Colors.white),
                          _prodlist(text1:prod1[10], text2:prod2[10],fill:Colors.white),
                          _prodlist(text1:prod1[11], text2:prod2[11],fill:Colors.white),
                          _prodlist(text1:prod1[12], text2:prod2[12],fill:Colors.white),
                          _prodlist(text1:prod1[13], text2:prod2[13],fill:Colors.white),
                          _prodlist(text1:prod1[14], text2:prod2[14],fill:Colors.white), */
                        ],               //children of left column
                    ),                   // end of left column
                ),                      // end of Expanded

                SizedBox(width:5),      // space between left and right sides
// ----------------------------------------------------------------------------------------------------------
                                        // start of the right column
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,   // align right
                        mainAxisAlignment: MainAxisAlignment.start,   // start from top
                        children: [
                          SizedBox(height: 3),
                          _prodlist(text1:'Product', text2:'Mol fraction', fill:Colors.blue.shade200),
                          _prodlist(text1:prod1[9], text2:prod2[9],fill:Colors.white),
                          _prodlist(text1:prod1[10], text2:prod2[10],fill:Colors.white),
                          _prodlist(text1:prod1[11], text2:prod2[11],fill:Colors.white),
                          _prodlist(text1:prod1[12], text2:prod2[12],fill:Colors.white),
                          _prodlist(text1:prod1[13], text2:prod2[13],fill:Colors.white),
                          _prodlist(text1:prod1[14], text2:prod2[14],fill:Colors.white),
                          _prodlist(text1:prod1[15], text2:prod2[15],fill:Colors.white),
                          _prodlist(text1:prod1[16], text2:prod2[16],fill:Colors.white),
                          _prodlist(text1:"  Smoke",   text2:prod2[17],fill:Colors.grey),
                        ],                               // end of children of Right column

                    ),                                   // end of Right side column
                ),                                       // end of second expanded
            ],                                           // end of main Children
        ),                                               // end of Main Row
          ],
          ),  // main main column
      ),                                   // end of Main Padding
      ),
    );                                  // end of Scaffold

  } // end of build Widget


  // Helper function to build Result Boxes
  Widget _buildResultBox( String value, Color fill, double w ) {
    return Container(
      //margin: EdgeInsets.only(right:100),
      //width: double.infinity,
      width: w, //250,  //double.infinity,
      height:26,
      //padding: EdgeInsets.only(1),
      decoration: BoxDecoration(
        color: fill, //grey[100],
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
      //  mainAxisAlignment: MainAxisAlignment.start,
      //  crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        /*  Text(
            title,
            style: TextStyle(fontSize:10),
            textDirection: TextDirection.ltr,
          ),*/
          SizedBox(height: 8),
          Text(value.isNotEmpty ? value : '       ',
            textDirection: TextDirection.ltr,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

Widget _outputBox(String value) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        height: 25,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(value, textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
             ),
      ),
    ),
  );
}





// Helper function to build input boxes for prayer times
  // Helper function to create input fields for
  Widget _buildInputField(String label, TextEditingController controller, bool show) {
    return 
      SizedBox(
       
        height: 25,
        
          child: TextField(
          style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
          controller: controller,
          enabled: show,
          decoration: InputDecoration(filled: true, fillColor:
                                                      Colors.lightGreen[200],
          labelText: label,
          labelStyle: TextStyle(fontSize:14, fontWeight: FontWeight.bold),
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
      
      );
    
  }

      Widget buildFuelSelector(){
        return Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blueGrey.shade200),
          ),
          child: DropdownButton<Fuel>(
            value: _selectedFuel,
            isExpanded: true,
            underline: SizedBox(), // Removes the default underline
            icon: Icon(Icons.local_gas_station, color: Colors.blue), // Add a fuel icon
            items: fuelDatabase.map((Fuel fuel) {
              return DropdownMenuItem<Fuel>(
                value: fuel,
                child: Text(
                  fuel.name,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
            onChanged: (Fuel? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedFuel = newValue;
                  // This is where you trigger your NASA-7 solver update
                });
              }
            },
          ),
        );
      }        // end of dropdown widget


// ----------------------------------Calculations Start Here

// Function to calculculate Flame Temp and species
  
  void _routine() {
  setState((){
  const R = 8.314462618;
  final M = List.filled(3, 0.0);  //List<double> M = []; //, Rho, H, U, S; // mixture molecular mass, density, 
  final Rho = List.filled(3, 0.0);  
  final H = List.filled(3, 0.0);                              //  enthalpy, int energy and entropy
  final eta = List.filled(15, 0.0); // initialze gas species viscosity0
  final lamda = List.filled(15, 0.0); // initialze gas species conductivity
  final mw  = List.filled(17, 0.0); // species molecular weights initialized including Cgr
  final A = List.generate(5, (_) => List.filled(17, 0.0)); 
  final B = List.filled(5, 0.0);
  // 3. Stoichiometric air
  final double airO2 = stoichOxygen(_selectedFuel) / phi;
  final double airN2 = airO2 * 3.72759;
  final double airAR = airO2 * 0.044707;
  final double airCO2= airO2 * 0.0015229;
  bool soot = false; 
  bool liquid = false; 
  double pSat = exp(11.67 - 3816.44 / (T_air - 46.13)); 
  double pH2O = RH/100.0 * pSat;
  double xH2O = pH2O / (P*1.01325);
  double n_vapor = airO2 * xH2O / (1.0 - xH2O);
  
  // 4. Element totals
  final Map<String, double> elements = {
    'C': _selectedFuel.C + 1.0*airCO2,
    'H': _selectedFuel.H + (n_vapor * 2.0) ,
    'O': _selectedFuel.O + 2.0*airO2  + 2*airCO2 + (n_vapor*1.0),
    'N': _selectedFuel.N + 2.0*airN2,
    'AR': airAR, 
  };
  B[0] = _selectedFuel.C + 1.0*airCO2;
  B[1] = _selectedFuel.H + (n_vapor * 2.0);
  B[2] = _selectedFuel.O + 2.0*airO2 + 2*airCO2 + (n_vapor*1.0);
  B[3] = _selectedFuel.N + 2.0*airN2;
  B[4] = airAR;

  List<Species> spec;
  spec = speciesList;
  final element = elements.keys.toList();
  for(int j = 0; j<17; j++){
    for (int i = 0; i < 5; i++) {
      final a = spec[j].atoms[element[i]] ?? 0;  
      A[i][j]= a.toDouble() ;
    }
  }  
  //  final Q = -72319.0;// fuel.hf; // heatOfCombustion(fuel);
  final Q = reactantEnthalpy(
          fuel:_selectedFuel, 
          airO2:airO2, 
          airN2:airN2,
          airAR:airAR, 
          airCO2:airCO2,
          n_vapor:n_vapor, 
          Tfuel:T_fuel, Tair:T_air,
  );
//  if product Temp is specified Tad = T specified and not calculated
  double T = 1000.0;  // initial guess of T if not specified
  GlobalData.T_calc=true;
  if(T_specified>=275.0){
    T = T_specified;
    GlobalData.Tad = T;
    GlobalData.T_calc=false;
  }
   
  final eq = gibbsMinimize(
    species: speciesList,
    elementTotals: elements,
    Q : Q,
    soot : soot,
    liquid : liquid,
    B : B,
    A : A,
    P : P,
    T : T,
  );    

// ************************ RESULTS READY *********************
T = GlobalData.Tad;
soot = GlobalData.soot1;
liquid = GlobalData.liquid1;
double totalMolesGas = eq.values.take(15).fold(0.0, (sum, n) => sum + n);  //including Cgr
double totalMolesAll = eq.values.fold(0.0, (sum, n) => sum + n);

int i = 0;
final N1 = List.filled(22, 1e-10);  // mole fractions
final moles  = List.filled(22, 0.0);  // absolute number of moles
eq.forEach((sp, n) {
  final x = n / totalMolesAll;
  moles[i] = n;
  N1[i] = x;
  prod1[i]="   ${sp.name}";
  prod2[i]='  ${x.toStringAsFixed(6)}'!;
  i += 1;
});
prod2[17] = '   NO ';
if(moles[15]>1.0e-5) prod2[17] = '   YES ';

GlobalData.T_calc=true;
//  
double air_mass =airO2*(2*15.9994 + 3.72759*2*14.00652 + 0.044707*39.948 + 0.0015229*44.095);
double F_mass = (_selectedFuel.C*12.0107 + _selectedFuel.H*1.00794 +_selectedFuel.O*15.9994+_selectedFuel.N*14.00652);  
  _AirToFuel= air_mass/F_mass;
 AFT = '${T.toStringAsFixed(1)}'; 
// totMoles = ' ${totalMolesAll.toStringAsFixed(5)}';
 AtoF = "${_AirToFuel.toStringAsFixed(2)}";
 Fuel_Hf="React H: ${Q.toStringAsFixed(1)} J/mol";


//   =====  properties should based on gas species only ============================
List<Visc>spp;
spp = ViscCoeff; 
// molecular weight of mixture
// get molecular mass of all species 0, 1, 2,...,15 including soot
H[0] = 0.0;
M[0] = 0.0;
double CP_F = 0.0;
int I = 0;
//if(soot == true) I = 1;
for (int i = 0; i < (15+1); i++){
  N1[i] = moles[i]/totalMolesGas;
  mw[i] = spp[i].mw;
  M[0] += N1[i]*mw[i];
  CP_F += N1[i]*cpNASA(spec[i].thermo, T );
  H[0] += N1[i]*enthalpyNASA(spec[i].thermo, T);
}
// add condensed water mw and enthalpy

if(T > 273.15 && T < 600){
N1[16] = moles[16]/totalMolesGas;
double hwater = N1[16]*h_water(T); //enthalpyNASA(spec[16].thermo,T);
double mw_water = N1[16]*mw[6];
M[0] += mw_water;
H[0] += hwater;
}

H[0] = H[0]/M[0];
CP_F = CP_F/M[0];
double Mgas = M[0]-N1[15]*mw[15] - N1[16]*mw[6]; // rho is calculated for M gas only
Rho[0] = P*101.325/(R/M[0]*T);
_rho = '${Rho[0].toStringAsFixed(4)}';
_m_wt = '${M[0].toStringAsFixed(3)}';

// get species viscoities - for gases only 0, 1, ...,14 don't include soont 
for (int i = 0; i<15; i++){
  eta[i] = spp[i].get_visc(T);
}
// get species thermal conductivities for gases only
List<Cond>spp1;
spp1 = CondCoeff;
for (int i = 0; i<15; i++){
  lamda[i] = spp1[i].get_cond(T);
}

// get visc and cond interaction coefficients fi and epsi

List<List<double>> fii = phii(1, mw, 15, eta);
double etamix = 0.0;
for (int i = 0; i < 15; i++){
  double s = 0.0;
  for (int j = 0; j < 15; j++){
    s += N1[j]*fii[i][j];
  }
  etamix += N1[i]*eta[i]/s;
}
//  print('etaMix $etamix');
_visc = '${(etamix*1.0e-7).toStringAsExponential(3)}';
List<List<double>> psi = phii(2, mw, 15, eta);
double lamdamix = 0.0;
for (int i = 0; i < 15; i++){
  double s = 0.0;
  for (int j = 0; j < 15; j++){
    s += N1[j]*psi[i][j];
  }
  lamdamix += N1[i]*lamda[i]/s;
}
// print('lamdaMix $lamdamix');
_cond = '${(lamdamix*1.0e-4).toStringAsFixed(5)}';

// Calculate heat rejected or added
double heat = 0.0;
double Hprod = 0.0;
I = 0;
if(soot== true) I =1;
for(int j = 0; j < 15+I; j++) {
  Hprod += moles[j] * enthalpyNASA(spec[j].thermo, T);
}
if(moles[16]>1.0e-10){
  Hprod += moles[16] * enthalpyNASA(spec[16].thermo, T);
}
heat = (Q - Hprod)/F_mass;
if(heat > -1.0e-6 && heat < 1.0e-6)heat = 0.0;
//print('heat $heat kJ/kg Fuel');
_heat = '${heat.toStringAsExponential(5)}';


// Finite Difference Logic for Thermal Properties Cp sonic_V


double DT = 1.0e0;
double Told = T;
GlobalData.T_calc = false; // Don't calculate T it is given

int sign = 1;
for (int i = 0; i < 2; i++){
  double TT = Told - DT*sign;
  sign = - sign;
  final eq = gibbsMinimize(species: speciesList, elementTotals: elements,
    Q : Q, soot : soot, liquid:liquid, B : B, A : A, P : P, T : TT,
  );    
  double totalMoles1 = eq.values.take(15).fold(0.0, (sum, n) => sum + n);
//  print('Tot mole $totalMoles');
  //   store mole fractions in N1[0, 1, ....,15]
  int k = -1;
  eq.forEach((sp, n) {
    final x = n / totalMoles1;
    k += 1;
    moles[k] = n;
    N1[k] = x;
  });
  
  M[i+1] = 0.0;
  H[i+1] = 0.0;
  int I = 0;
  if(soot) I= 1;
  for (int j = 0; j < I+15 ; j++){
    M[i+1] += N1[j]*mw[j];
    H[i+1] += N1[j]*enthalpyNASA(spec[j].thermo, TT); 
  }
  if(N1[16] > 0.0){
    M[i+1] += N1[16]*mw[6];
    H[i+1] += N1[16]*enthalpyNASA(spec[16].thermo, TT);
  }
}

double U0 = H[0] - R*Told/M[0];
double U1 = H[1]/M[1] - R*(Told-DT)/M[1];
double U2 = H[2]/M[2] - R*(Told+DT)/M[2];
//print('U0 $U0');
//print('U1 $U1  U2 $U2');
double CV = (U2 - U1)/(2.0*DT);
double CP = (H[2]/M[2] - H[1]/M[1])/(2.0*DT);
double gamas = CP/CV;
//print('gamas $gamas');
double sonic = sqrt(gamas*R*1000.0/M[0]*Told);
//print('CPeq = ${CP.toStringAsFixed(4)}');
//print('sonic speed ${sonic.toStringAsFixed(2)}');
_cp = '${CP.toStringAsFixed(4)}';
_sonic = '${sonic.toStringAsFixed(2)}';

}
  );  // end of setState
  }  // end of routine 





// ***************** END OF WIDGET BUILD
}

class _prodlist extends StatelessWidget {
   final String text1;
   final String text2;
   final Color fill; // = Colors.blue;
const _prodlist({required this.text1, required this.text2, required this.fill,super.key});
//  const _prodlist({required this.text1, required this.text2, this.fill,super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Row(
        children: [
          DecoratedBox( decoration:
            BoxDecoration(color: fill, border:Border.all(color:Colors.blue),
                          borderRadius:BorderRadius.circular(8),
            ),
            child: SizedBox(width:80, height:25, 
              child: Align(alignment: Alignment.centerLeft,
                child:Text(text1, 
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                ),
            ),
          ),

          SizedBox(width: 2),
          DecoratedBox(decoration:
            BoxDecoration(color: fill, border:Border.all(color:Colors.blue),
                          borderRadius:BorderRadius.circular(8),
            ),
            child: SizedBox(width:70, height:25, 
              child: Align(alignment: Alignment.centerLeft,
                child:Text(text2, 
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                ),
            ),
          ),
          
        ],
      ),
    );
  }
}