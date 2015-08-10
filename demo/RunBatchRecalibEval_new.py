import os,sys;
import glob;

if __name__ == '__main__':
	img_dirs = ['/data/SSD/vela/gt/mar12a/PNG']
	output_filepath = '../input_mar12a.param'
	output_file = open(output_filepath,'w');
	for img_dir in img_dirs:
		gp2img_dict = dict(); #<all#_00##, [00001, 00051, 00101,...]>
		num2gp_dict = dict(); #<0, all#_00##>
		img_filepaths = glob.glob('%s/all*_left.png'%(img_dir));
		for img_filepath in img_filepaths:
			img_name = img_filepath.split('/')[-1];
			items = img_name.split('_');
			gp_id = items[0] + '_' + items[1] + '_' + items[2];
			img_id = items[3];
			gp_num = int(items[2]);
			if not gp2img_dict.has_key(gp_id):
				gp2img_dict[gp_id] = [];
				num2gp_dict[gp_num] = gp_id;
			gp2img_dict[gp_id].append(img_id);
		for (k,gp_id) in num2gp_dict.items():
			output_file.write('%s\t'%(gp_id));
			for idx, img_id in enumerate(gp2img_dict[gp_id]):
				left_img_path = "%s/%s_%s_left.png"%(img_dir, gp_id, img_id);
				right_img_path = "%s/%s_%s_right.png"%(img_dir, gp_id, img_id);
				if idx == 0:
					output_file.write('%s:%s'%(left_img_path, right_img_path));
				elif idx <= 6:
					output_file.write(',%s:%s'%(left_img_path, right_img_path));
			output_file.write('\n');
	output_file.close();
