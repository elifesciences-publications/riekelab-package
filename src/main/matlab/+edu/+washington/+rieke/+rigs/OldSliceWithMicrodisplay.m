classdef OldSliceWithMicrodisplay < edu.washington.rieke.rigs.OldSlice
    
    methods
        
        function obj = OldSliceWithMicrodisplay()
            import symphonyui.builtin.devices.*;
            
            ramps = containers.Map();
            ramps('minimum') = linspace(0, 65535, 256);
            ramps('low')     = obj.MICRODISPLAY_LOW_GAMMA_RAMP * 65535;
            ramps('medium')  = obj.MICRODISPLAY_MEDIUM_GAMMA_RAMP * 65535;
            ramps('high')    = obj.MICRODISPLAY_HIGH_GAMMA_RAMP * 65535;
            ramps('maximum') = linspace(0, 65535, 256);
            microdisplay = edu.washington.rieke.devices.MicrodisplayDevice(ramps);
            microdisplay.addConfigurationSetting('micronsPerPixel', 1.2, 'isReadOnly', true);
            obj.addDevice(microdisplay);
            
            frameMonitor = UnitConvertingDevice('Frame Monitor', 'V').bindStream(obj.daqController.getStream('ANALOG_IN.7'));
            obj.addDevice(frameMonitor);
        end
        
    end
    
    properties (Constant)
        
        MICRODISPLAY_LOW_GAMMA_RAMP = [ ...
            0.188235;
            0.246918;
            0.255629;
            0.262379;
            0.267679;
            0.272302;
            0.276332;
            0.280018;
            0.283733;
            0.287325;
            0.290750;
            0.293861;
            0.297118;
            0.300388;
            0.303618;
            0.306831;
            0.310069;
            0.313052;
            0.318574;
            0.322186;
            0.325094;
            0.327840;
            0.330492;
            0.333051;
            0.335553;
            0.338059;
            0.340590;
            0.343124;
            0.345638;
            0.348082;
            0.351050;
            0.354535;
            0.357976;
            0.360908;
            0.363618;
            0.366311;
            0.369005;
            0.371779;
            0.374607;
            0.377437;
            0.380232;
            0.383150;
            0.385982;
            0.388800;
            0.391818;
            0.395091;
            0.398358;
            0.401566;
            0.404712;
            0.407801;
            0.410806;
            0.413842;
            0.416887;
            0.419931;
            0.423043;
            0.426063;
            0.429121;
            0.432455;
            0.436639;
            0.440965;
            0.444585;
            0.447921;
            0.451030;
            0.454108;
            0.457199;
            0.460293;
            0.463399;
            0.466549;
            0.469581;
            0.472571;
            0.475682;
            0.479290;
            0.483947;
            0.488157;
            0.491615;
            0.494772;
            0.497924;
            0.500372;
            0.502981;
            0.505953;
            0.509087;
            0.512254;
            0.515312;
            0.518255;
            0.521150;
            0.525072;
            0.529424;
            0.533411;
            0.536517;
            0.539484;
            0.542431;
            0.545399;
            0.548281;
            0.551234;
            0.554236;
            0.557239;
            0.560015;
            0.562722;
            0.565559;
            0.568839;
            0.572126;
            0.575153;
            0.578084;
            0.581005;
            0.584058;
            0.586876;
            0.589723;
            0.592650;
            0.595756;
            0.598781;
            0.601597;
            0.604398;
            0.608029;
            0.612288;
            0.615959;
            0.618780;
            0.621711;
            0.624636;
            0.627476;
            0.630306;
            0.633157;
            0.635997;
            0.638764;
            0.641583;
            0.644396;
            0.647254;
            0.651390;
            0.655678;
            0.659107;
            0.662045;
            0.664931;
            0.667692;
            0.670286;
            0.673013;
            0.675832;
            0.678718;
            0.681425;
            0.684186;
            0.687041;
            0.690097;
            0.694151;
            0.697611;
            0.700663;
            0.703478;
            0.706149;
            0.708752;
            0.711389;
            0.714052;
            0.716742;
            0.719559;
            0.722375;
            0.725042;
            0.727744;
            0.730563;
            0.733546;
            0.736343;
            0.739086;
            0.741782;
            0.744403;
            0.747007;
            0.749525;
            0.751767;
            0.754215;
            0.756888;
            0.759292;
            0.761883;
            0.764808;
            0.768826;
            0.772488;
            0.775421;
            0.778111;
            0.780686;
            0.783368;
            0.785971;
            0.788549;
            0.791253;
            0.793808;
            0.796296;
            0.798872;
            0.801642;
            0.804833;
            0.808766;
            0.812058;
            0.814603;
            0.817145;
            0.819683;
            0.822128;
            0.824602;
            0.827116;
            0.829749;
            0.832383;
            0.834988;
            0.837500;
            0.840251;
            0.843609;
            0.847276;
            0.850221;
            0.852863;
            0.855373;
            0.857774;
            0.860335;
            0.862998;
            0.865477;
            0.867946;
            0.870408;
            0.872773;
            0.875119;
            0.877434;
            0.879868;
            0.882394;
            0.884908;
            0.887403;
            0.889876;
            0.892363;
            0.894824;
            0.897222;
            0.899708;
            0.902227;
            0.904647;
            0.907093;
            0.909566;
            0.912792;
            0.916157;
            0.919048;
            0.921550;
            0.924010;
            0.926412;
            0.928726;
            0.931236;
            0.933778;
            0.936104;
            0.938373;
            0.940585;
            0.943002;
            0.945661;
            0.949195;
            0.952719;
            0.955278;
            0.957771;
            0.960260;
            0.962635;
            0.964973;
            0.967258;
            0.969576;
            0.971943;
            0.974320;
            0.976715;
            0.979235;
            0.982214;
            0.985421;
            0.988340;
            0.990793;
            0.993186;
            0.995504;
            0.997762;
            1.000000];
        
        MICRODISPLAY_MEDIUM_GAMMA_RAMP = [ ...
            0.070588;
            0.239893;
            0.249010;
            0.254947;
            0.259651;
            0.263837;
            0.267718;
            0.271233;
            0.274574;
            0.277674;
            0.280936;
            0.284584;
            0.288577;
            0.291748;
            0.294327;
            0.296917;
            0.299321;
            0.301585;
            0.303762;
            0.305922;
            0.308084;
            0.310209;
            0.312190;
            0.314332;
            0.317031;
            0.319361;
            0.321582;
            0.323675;
            0.325758;
            0.327787;
            0.329845;
            0.332023;
            0.334183;
            0.336317;
            0.338660;
            0.341166;
            0.344810;
            0.347908;
            0.350676;
            0.353282;
            0.355880;
            0.358517;
            0.361186;
            0.363894;
            0.366653;
            0.369431;
            0.372203;
            0.375293;
            0.378752;
            0.382163;
            0.385312;
            0.388333;
            0.391420;
            0.394379;
            0.397357;
            0.400427;
            0.403548;
            0.406593;
            0.409684;
            0.413164;
            0.417658;
            0.421889;
            0.425325;
            0.428503;
            0.431643;
            0.434724;
            0.437827;
            0.440917;
            0.444023;
            0.447212;
            0.450413;
            0.453829;
            0.457722;
            0.461515;
            0.464916;
            0.468132;
            0.471278;
            0.474363;
            0.477471;
            0.480584;
            0.483680;
            0.486760;
            0.489879;
            0.493288;
            0.497781;
            0.501289;
            0.504540;
            0.507787;
            0.510997;
            0.514086;
            0.517072;
            0.519963;
            0.522944;
            0.526020;
            0.528886;
            0.532021;
            0.535275;
            0.538494;
            0.541618;
            0.544848;
            0.547881;
            0.550906;
            0.553921;
            0.556903;
            0.559927;
            0.562787;
            0.565682;
            0.568854;
            0.572993;
            0.577418;
            0.580882;
            0.583974;
            0.586955;
            0.589917;
            0.592940;
            0.596164;
            0.599184;
            0.602031;
            0.604901;
            0.607969;
            0.611509;
            0.615436;
            0.618576;
            0.621548;
            0.624513;
            0.627572;
            0.630420;
            0.633339;
            0.636289;
            0.639232;
            0.642149;
            0.645284;
            0.649088;
            0.653308;
            0.656762;
            0.659780;
            0.662683;
            0.665752;
            0.668551;
            0.671280;
            0.674155;
            0.677109;
            0.679909;
            0.682635;
            0.686000;
            0.689189;
            0.692315;
            0.695273;
            0.698030;
            0.700909;
            0.703713;
            0.706479;
            0.709267;
            0.712036;
            0.714813;
            0.717611;
            0.721343;
            0.725748;
            0.729077;
            0.732007;
            0.734818;
            0.737569;
            0.740333;
            0.743123;
            0.745899;
            0.748612;
            0.750925;
            0.753258;
            0.756407;
            0.759839;
            0.762924;
            0.765781;
            0.768509;
            0.771263;
            0.774044;
            0.776838;
            0.779566;
            0.782315;
            0.785056;
            0.787758;
            0.791218;
            0.795105;
            0.798436;
            0.801342;
            0.804031;
            0.806751;
            0.809370;
            0.811925;
            0.814530;
            0.817095;
            0.819629;
            0.822061;
            0.824592;
            0.827276;
            0.830238;
            0.832991;
            0.835602;
            0.838208;
            0.840792;
            0.843376;
            0.846090;
            0.848822;
            0.851514;
            0.854016;
            0.857042;
            0.860781;
            0.864351;
            0.867266;
            0.869910;
            0.872525;
            0.875132;
            0.877747;
            0.880344;
            0.882928;
            0.885490;
            0.888070;
            0.890794;
            0.894143;
            0.897170;
            0.899876;
            0.902458;
            0.905062;
            0.907637;
            0.910188;
            0.912681;
            0.915193;
            0.917717;
            0.920198;
            0.923171;
            0.926793;
            0.930273;
            0.933211;
            0.935583;
            0.937913;
            0.940203;
            0.942652;
            0.945211;
            0.947635;
            0.950112;
            0.952661;
            0.955306;
            0.957633;
            0.959492;
            0.961742;
            0.964879;
            0.967999;
            0.971382;
            0.974950;
            0.978270;
            0.981430;
            0.984679;
            0.987605;
            0.990620;
            0.994010;
            0.997293;
            1.000000];
        
        MICRODISPLAY_HIGH_GAMMA_RAMP = [ ...
            0.066667;
            0.235573;
            0.245135;
            0.250232;
            0.254575;
            0.258331;
            0.261588;
            0.264633;
            0.267505;
            0.270179;
            0.273037;
            0.276475;
            0.279953;
            0.282794;
            0.285071;
            0.287293;
            0.289455;
            0.291514;
            0.293519;
            0.295586;
            0.297679;
            0.300015;
            0.302366;
            0.304557;
            0.306638;
            0.308549;
            0.310418;
            0.312205;
            0.314002;
            0.315862;
            0.317733;
            0.319848;
            0.322100;
            0.324949;
            0.327193;
            0.329294;
            0.331325;
            0.333352;
            0.335417;
            0.337489;
            0.339622;
            0.341797;
            0.344088;
            0.346635;
            0.349353;
            0.351855;
            0.354390;
            0.356947;
            0.359433;
            0.362027;
            0.364749;
            0.367352;
            0.370114;
            0.373261;
            0.377464;
            0.381047;
            0.383956;
            0.386905;
            0.389775;
            0.392594;
            0.395512;
            0.398458;
            0.401424;
            0.404493;
            0.408043;
            0.411926;
            0.415114;
            0.418209;
            0.421225;
            0.424209;
            0.427245;
            0.430274;
            0.433294;
            0.436374;
            0.439705;
            0.444066;
            0.448188;
            0.451409;
            0.454502;
            0.457619;
            0.460696;
            0.463766;
            0.466871;
            0.469818;
            0.472712;
            0.475713;
            0.478930;
            0.482191;
            0.485310;
            0.488426;
            0.491498;
            0.494521;
            0.497617;
            0.500159;
            0.502787;
            0.505902;
            0.510529;
            0.514795;
            0.518062;
            0.520895;
            0.523980;
            0.527045;
            0.530092;
            0.533419;
            0.536492;
            0.539507;
            0.542901;
            0.546834;
            0.550488;
            0.553706;
            0.556826;
            0.559737;
            0.562618;
            0.565562;
            0.568716;
            0.571739;
            0.574921;
            0.578862;
            0.583165;
            0.586601;
            0.589741;
            0.592874;
            0.596059;
            0.599129;
            0.602062;
            0.605030;
            0.608155;
            0.611218;
            0.614721;
            0.618052;
            0.621201;
            0.624260;
            0.627283;
            0.630200;
            0.633180;
            0.636201;
            0.639208;
            0.642182;
            0.645866;
            0.650264;
            0.653881;
            0.657005;
            0.660014;
            0.663048;
            0.666042;
            0.669000;
            0.671925;
            0.674846;
            0.677965;
            0.681527;
            0.685271;
            0.688381;
            0.691257;
            0.694143;
            0.696927;
            0.699934;
            0.703015;
            0.705957;
            0.708737;
            0.712143;
            0.716306;
            0.720131;
            0.723340;
            0.726298;
            0.729226;
            0.732189;
            0.735084;
            0.737921;
            0.740713;
            0.743398;
            0.746214;
            0.749253;
            0.751823;
            0.754596;
            0.757489;
            0.760255;
            0.763081;
            0.765981;
            0.768938;
            0.771699;
            0.774945;
            0.779105;
            0.782934;
            0.786071;
            0.788985;
            0.791932;
            0.794714;
            0.797530;
            0.800391;
            0.803233;
            0.806097;
            0.809237;
            0.812653;
            0.815721;
            0.818556;
            0.821313;
            0.824049;
            0.826895;
            0.829786;
            0.832631;
            0.835413;
            0.838300;
            0.842104;
            0.846206;
            0.849590;
            0.852544;
            0.855293;
            0.857969;
            0.860813;
            0.863670;
            0.866398;
            0.869150;
            0.872082;
            0.874952;
            0.876932;
            0.879437;
            0.883269;
            0.886388;
            0.890702;
            0.894265;
            0.898259;
            0.902012;
            0.905264;
            0.908962;
            0.912597;
            0.916307;
            0.919560;
            0.922505;
            0.925398;
            0.928210;
            0.931278;
            0.934298;
            0.936907;
            0.939552;
            0.942291;
            0.945164;
            0.947853;
            0.950695;
            0.953640;
            0.956534;
            0.959309;
            0.962130;
            0.964999;
            0.967699;
            0.970319;
            0.972908;
            0.975569;
            0.978384;
            0.981306;
            0.984291;
            0.986968;
            0.989512;
            0.991938;
            0.994770;
            0.997461;
            1.000000];
        
    end
    
end

