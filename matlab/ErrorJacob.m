function J = ErrorJacob(lamda, beta_l, beta_r, alpha_l, alpha_r, u0, v0, f, x_l, y_l, x_r, y_r)


Jalpha_l = (f*(sin(lamda/2)*cos(beta_l) + (sin(beta_l)*(u0 - x_l))/f - (cos(lamda/2)*cos(beta_l)*(v0 - y_l))/f)*(cos(lamda/2)*sin(alpha_l) - sin(lamda/2)*cos(alpha_l)*sin(beta_l) + ((v0 - y_l)*(sin(lamda/2)*sin(alpha_l) + cos(lamda/2)*cos(alpha_l)*sin(beta_l)))/f + (cos(alpha_l)*cos(beta_l)*(u0 - x_l))/f))/(cos(lamda/2)*cos(alpha_l) + sin(lamda/2)*sin(alpha_l)*sin(beta_l) + ((v0 - y_l)*(sin(lamda/2)*cos(alpha_l) - cos(lamda/2)*sin(alpha_l)*sin(beta_l)))/f - (cos(beta_l)*sin(alpha_l)*(u0 - x_l))/f)^2;

Jalpha_r = (f*(sin(lamda/2)*cos(beta_r) - (sin(beta_r)*(u0 - x_r))/f + (cos(lamda/2)*cos(beta_r)*(v0 - y_r))/f)*(cos(lamda/2)*sin(alpha_r) + sin(lamda/2)*cos(alpha_r)*sin(beta_r) - ((v0 - y_r)*(sin(lamda/2)*sin(alpha_r) - cos(lamda/2)*cos(alpha_r)*sin(beta_r)))/f + (cos(alpha_r)*cos(beta_r)*(u0 - x_r))/f))/(sin(lamda/2)*sin(alpha_r)*sin(beta_r) - cos(lamda/2)*cos(alpha_r) + ((v0 - y_r)*(sin(lamda/2)*cos(alpha_r) + cos(lamda/2)*sin(alpha_r)*sin(beta_r)))/f + (cos(beta_r)*sin(alpha_r)*(u0 - x_r))/f)^2;

Jbeta_l = f*(((cos(beta_l)*(u0 - x_l))/f - sin(lamda/2)*sin(beta_l) + (cos(lamda/2)*sin(beta_l)*(v0 - y_l))/f)/(cos(lamda/2)*cos(alpha_l) + sin(lamda/2)*sin(alpha_l)*sin(beta_l) + ((v0 - y_l)*(sin(lamda/2)*cos(alpha_l) - cos(lamda/2)*sin(alpha_l)*sin(beta_l)))/f - (cos(beta_l)*sin(alpha_l)*(u0 - x_l))/f) - ((sin(lamda/2)*cos(beta_l) + (sin(beta_l)*(u0 - x_l))/f - (cos(lamda/2)*cos(beta_l)*(v0 - y_l))/f)*(sin(lamda/2)*cos(beta_l)*sin(alpha_l) + (sin(alpha_l)*sin(beta_l)*(u0 - x_l))/f - (cos(lamda/2)*cos(beta_l)*sin(alpha_l)*(v0 - y_l))/f))/(cos(lamda/2)*cos(alpha_l) + sin(lamda/2)*sin(alpha_l)*sin(beta_l) + ((v0 - y_l)*(sin(lamda/2)*cos(alpha_l) - cos(lamda/2)*sin(alpha_l)*sin(beta_l)))/f - (cos(beta_l)*sin(alpha_l)*(u0 - x_l))/f)^2);

Jbeta_r = f*((sin(lamda/2)*sin(beta_r) + (cos(beta_r)*(u0 - x_r))/f + (cos(lamda/2)*sin(beta_r)*(v0 - y_r))/f)/(sin(lamda/2)*sin(alpha_r)*sin(beta_r) - cos(lamda/2)*cos(alpha_r) + ((v0 - y_r)*(sin(lamda/2)*cos(alpha_r) + cos(lamda/2)*sin(alpha_r)*sin(beta_r)))/f + (cos(beta_r)*sin(alpha_r)*(u0 - x_r))/f) + ((sin(lamda/2)*cos(beta_r) - (sin(beta_r)*(u0 - x_r))/f + (cos(lamda/2)*cos(beta_r)*(v0 - y_r))/f)*(sin(lamda/2)*cos(beta_r)*sin(alpha_r) - (sin(alpha_r)*sin(beta_r)*(u0 - x_r))/f + (cos(lamda/2)*cos(beta_r)*sin(alpha_r)*(v0 - y_r))/f))/(sin(lamda/2)*sin(alpha_r)*sin(beta_r) - cos(lamda/2)*cos(alpha_r) + ((v0 - y_r)*(sin(lamda/2)*cos(alpha_r) + cos(lamda/2)*sin(alpha_r)*sin(beta_r)))/f + (cos(beta_r)*sin(alpha_r)*(u0 - x_r))/f)^2);

Jlamda = f*(((cos(lamda/2)*cos(beta_l))/2 + (sin(lamda/2)*cos(beta_l)*(v0 - y_l))/(2*f))/(cos(lamda/2)*cos(alpha_l) + sin(lamda/2)*sin(alpha_l)*sin(beta_l) + ((v0 - y_l)*(sin(lamda/2)*cos(alpha_l) - cos(lamda/2)*sin(alpha_l)*sin(beta_l)))/f - (cos(beta_l)*sin(alpha_l)*(u0 - x_l))/f) - ((cos(lamda/2)*cos(beta_r))/2 - (sin(lamda/2)*cos(beta_r)*(v0 - y_r))/(2*f))/(sin(lamda/2)*sin(alpha_r)*sin(beta_r) - cos(lamda/2)*cos(alpha_r) + ((v0 - y_r)*(sin(lamda/2)*cos(alpha_r) + cos(lamda/2)*sin(alpha_r)*sin(beta_r)))/f + (cos(beta_r)*sin(alpha_r)*(u0 - x_r))/f) - ((sin(lamda/2)*cos(beta_l) + (sin(beta_l)*(u0 - x_l))/f - (cos(lamda/2)*cos(beta_l)*(v0 - y_l))/f)*((cos(lamda/2)*sin(alpha_l)*sin(beta_l))/2 - (sin(lamda/2)*cos(alpha_l))/2 + ((v0 - y_l)*((cos(lamda/2)*cos(alpha_l))/2 + (sin(lamda/2)*sin(alpha_l)*sin(beta_l))/2))/f))/(cos(lamda/2)*cos(alpha_l) + sin(lamda/2)*sin(alpha_l)*sin(beta_l) + ((v0 - y_l)*(sin(lamda/2)*cos(alpha_l) - cos(lamda/2)*sin(alpha_l)*sin(beta_l)))/f - (cos(beta_l)*sin(alpha_l)*(u0 - x_l))/f)^2 + ((sin(lamda/2)*cos(beta_r) - (sin(beta_r)*(u0 - x_r))/f + (cos(lamda/2)*cos(beta_r)*(v0 - y_r))/f)*((sin(lamda/2)*cos(alpha_r))/2 + (cos(lamda/2)*sin(alpha_r)*sin(beta_r))/2 + ((v0 - y_r)*((cos(lamda/2)*cos(alpha_r))/2 - (sin(lamda/2)*sin(alpha_r)*sin(beta_r))/2))/f))/(sin(lamda/2)*sin(alpha_r)*sin(beta_r) - cos(lamda/2)*cos(alpha_r) + ((v0 - y_r)*(sin(lamda/2)*cos(alpha_r) + cos(lamda/2)*sin(alpha_r)*sin(beta_r)))/f + (cos(beta_r)*sin(alpha_r)*(u0 - x_r))/f)^2);

J =  [Jlamda, Jbeta_l, Jbeta_r, Jalpha_l, Jalpha_r];
% 
% sl2 = sin( lamda/2 );
% cl2 = cos( lamda/2 );
% sbl = sin( beta_l );
% cbl = cos( beta_l );
% sbr = sin( beta_r );
% cbr = cos( beta_r );
% sal = sin( alpha_l );
% cal = cos( alpha_l );
% sar = sin( alpha_r );
% car = cos( alpha_r );
% 
% u0sxl = ( u0 - x_l );
% u0sxr = ( u0 - x_r );
% v0syl = ( v0 - y_l );
% v0syr = ( v0 - y_r );
% 
% sl2tcbl = sl2 * cbl;
% cl2tsal = cl2 * sal;
% sl2tsal = sl2 * sal;
% caltcbl = cal * cbl;
% cl2tcal = cl2 * cal;
% sl2tcal = sl2 * cal;
% sl2tcbr = sl2 * cbr;
% cl2tcbl = cl2 * cbl;
% cl2tcbr = cl2 * cbr;
% cl2tsar = cl2 * sar;
% sl2tsar = sl2 * sar;
% cl2tcar = cl2 * car;
% sl2tcar = sl2 * car;
% sartsbr = sar * sbr;
% cbrtsar = cbr * sar;
% sl2tsbl = sl2 * sbl;
% 
% sbltu0sxl = sbl * u0sxl;
% saltu0sxl = sal * u0sxl;
% cbltu0sxl = cbl * u0sxl;
% sbrtu0sxr = sbr * u0sxr;
% cbrtu0sxr = cbr * u0sxr;
% 
% cl2tsartsbr = cl2 * sartsbr;
% sl2tsartsbr = sl2tsar * sbr;
% sl2tcaltsbl = sl2tcal * sbl;
% sl2tcartsbr = sl2 * car * sbr;
% cl2tcbltv0syl = (cl2tcbl * v0syl);
% sl2tsaltsbl = (sl2tsal * sbl);
% cl2tsaltsbl = cl2tsal * sbl;
% sl2tcbrtsar = sl2 * cbr * sar;
% cbltsaltu0sxl = cbl * saltu0sxl;
% cbrtsartu0sxr = cbrtsar * u0sxr;
% caltcbltu0sxl = cal* cbl * u0sxl;
% cl2tcbrtv0syr = (cl2tcbr * v0syr);
% 
% sl2tcalscl2tsaltsbl = ( sl2tcal - cl2tsaltsbl );
% sl2tcarpcl2tsartsbr = ( sl2tcar + cl2tsartsbr );
% 
% Jalpha_l = (f*(sl2tcbl + sbltu0sxl/f - cl2tcbltv0syl/f)*(cl2tsal - sl2tcaltsbl + (v0syl*(sl2tsal + cl2tcal*sbl))/f + (caltcbltu0sxl)/f))/(cl2tcal + sl2tsaltsbl + (v0syl*sl2tcalscl2tsaltsbl)/f - cbltsaltu0sxl/f)^2;
% 
% Jalpha_r = (f*(sl2tcbr - (sbrtu0sxr)/f + cl2tcbrtv0syr/f)*(cl2tsar + sl2tcartsbr - (v0syr*(sl2tsar - cl2tcar*sbr))/f + (car*cbrtu0sxr)/f))/(sl2tsartsbr - cl2tcar + (v0syr*sl2tcarpcl2tsartsbr)/f + cbrtsartu0sxr/f)^2;
% 
% 
% Jbeta_l = f*(((cbltu0sxl)/f - sl2tsbl + (cl2*sbl*v0syl)/f)/(cl2tcal + sl2tsaltsbl + (v0syl*sl2tcalscl2tsaltsbl)/f - cbltsaltu0sxl/f) - ((sl2tcbl + sbltu0sxl/f - cl2tcbltv0syl/f)*(sl2tcbl*sal + (sal*sbl*u0sxl)/f - (cl2tcbl*sal*v0syl)/f))/(cl2tcal + sl2tsaltsbl + (v0syl*sl2tcalscl2tsaltsbl)/f - cbltsaltu0sxl/f)^2);
% 
% Jbeta_r = f*((sl2*sbr + (cbrtu0sxr)/f + (cl2*sbr*v0syr)/f)/(sl2tsartsbr - cl2tcar + (v0syr*sl2tcarpcl2tsartsbr)/f + cbrtsartu0sxr/f) + ((sl2tcbr - (sbrtu0sxr)/f + cl2tcbrtv0syr/f)*(sl2tcbrtsar - (sartsbrtu0sxr)/f + (cl2tcbrtsar*v0syr)/f))/(sl2tsartsbr - cl2tcar + (v0syr*sl2tcarpcl2tsartsbr)/f + cbrtsartu0sxr/f)^2);
% 
% Jlamda = f*(((cl2tcbl)/2 + (sl2tcbl*v0syl)/(2*f))/(cl2tcal + sl2tsaltsbl + (v0syl*sl2tcalscl2tsaltsbl)/f - cbltsaltu0sxl/f) - ((cl2tcbr)/2 - (sl2tcbr*v0syr)/(2*f))/(sl2tsartsbr - cl2tcar + (v0syr*sl2tcarpcl2tsartsbr)/f + cbrtsartu0sxr/f) - ((sl2tcbl + sbltu0sxl/f - cl2tcbltv0syl/f)*((cl2tsaltsbl)/2 - (sl2tcal)/2 + (v0syl*((cl2tcal)/2 + (sl2tsaltsbl)/2))/f))/(cl2tcal + sl2tsaltsbl + (v0syl*sl2tcalscl2tsaltsbl)/f - cbltsaltu0sxl/f)^2 + ((sl2tcbr - (sbrtu0sxr)/f + cl2tcbrtv0syr/f)*((sl2tcar)/2 + (cl2tsartsbr)/2 + (v0syr*((cl2tcar)/2 - (sl2tsartsbr)/2))/f))/(sl2tsartsbr - cl2tcar + (v0syr*sl2tcarpcl2tsartsbr)/f + cbrtsartu0sxr/f)^2);
% 

end