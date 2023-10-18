function [] = plot_penobjs_combined_pareto_callback(gcbo, eventdata, NC, CA_all, design_array, constr_array, heur_array, penobjs_array, max_rad, acc_rad_fac, constrad_read)

point_pos = get(gca, 'Currentpoint');

point_pos_comp = [-point_pos(1,1), point_pos(1,2)]; % objective 1 is to be maximized and objective 2 is to be minimized

euclid_dist = zeros(size(penobjs_array,1),1);
for i = 1:size(penobjs_array,1)
    current_point = penobjs_array(i,:);
    euclid_dist(i) = sqrt((current_point(1) - point_pos_comp(1))^2 + (current_point(2) - point_pos_comp(2))^2);
end
[~,min_index] = min(euclid_dist);

scatter(gca, -penobjs_array(:,1), penobjs_array(:,2), 'Marker', 'o', 'MarkerEdgeColor', 'black', 'ButtonDownFcn', {@plot_penobjs_combined_pareto_callback,NC,CA_all,design_array, constr_array, heur_array, penobjs_array, max_rad, acc_rad_fac, constrad_read}) 
hold on
plot(gca,-penobjs_array(min_index,1),penobjs_array(min_index,2),'*r')
hold off
xlabel('Penalized $C_{22}$','Interpreter','Latex')
ylabel('Penalized $v_f$','Interpreter','Latex')

if constrad_read
    point_design = design_array(min_index);
    point_des_char = point_design{1,1};
    design_bool = zeros(size(point_des_char,2),1);
    for i = 1:size(point_des_char,2)
        design_bool(i) = str2num(point_des_char(i));
    end
    CA_des = CA_all(design_bool~=0,:);
    visualize_truss_constrad(NC,CA_des)
else
    point_design = design_array(min_index,:);
    design_bool = zeros(size(point_design,2),1);
    for i = 1:size(point_design,2)
        design_bool(i) = point_design(i) > acc_rad_fac*max_rad;
    end
    radius_array = point_design(design_bool~=0);
    CA_des = CA_all(design_bool~=0,:);
    visualize_truss_varrad(NC,CA_des,radius_array,max_rad,acc_rad_fac)
end

disp(strcat('Feasibility Score = ',num2str(constr_array(min_index,1))))
disp(strcat('Connectivity Score = ',num2str(constr_array(min_index,2))))
if constrad_read
    disp(strcat('Absolute Stiffness Ratio Constraint = ',num2str(constr_array(min_index,3))))
else
    disp(strcat('Absolute Stiffness Ratio Constraint = ',1 - num2str(constr_array(min_index,3))))
    % based on faulty saving of 1 - constraint through java code, rectified
    % in post (change if new data taken)
    disp('Radius Array = ')
    perline = 6;
    %fmt = [repmat('%f',1,perline), '\n'];
    %fprintf(fmt, point_design);
    %if mod(length(point_design), perline ~= 0)
        %fprintf('\n');
    %end
    %disp(mat2str(radius_array))
end
disp(strcat('Partial Collapsibility Score = ',num2str(heur_array(min_index,1))))
disp(strcat('Nodal Properties Score = ',num2str(heur_array(min_index,2))))
disp(strcat('Orientation Score = ',num2str(heur_array(min_index,3))))
fprintf('\n')

end