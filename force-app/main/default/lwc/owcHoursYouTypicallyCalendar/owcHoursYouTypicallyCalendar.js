import {LightningElement,track,api} from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import {radioOptions,acceptedFileFormat,customLabelValues} from 'c/owcUtils'
export default class PptTesting extends LightningElement {


	@api isLargeDevice = false;
    @api isMediumDevice = false;
    @api isSmallDevice = false;

	// Custom Label Values
	customLabelValues = customLabelValues;
	//Public accessible var to get No of days in a week
	@api week_No;
	@track sameSchedule;
	@api timeentrydetail;
	@api isrenderedtimecalendar;
	@api workweekvalue
	@api isformpreviewmode = false
	@api
	getWeekDaysDetails() {
		const res = this;
		const timeEntriesDetails = this.timeEntriesDetails
		const selectEvent = new CustomEvent('timeentriesevent', {
			detail: {
				timeEntriesDetailed: timeEntriesDetails
			}
		});
		res.dispatchEvent(selectEvent);
	}

	@track isRecursive = false;
	@track timeEntryDetailDayBeforeSelectedDay = [];

	@track timeEntriesDetails = [{
			name: "Sunday",
			startTime: "",
			endTime: "",
			dateDiffer: false,
			isFirstMeal: false,
			isSecondMeal: false,
			startTimeFirstMeal: "",
			breakTimeFirstMeal: "",
			startTimeSecondMeal: "",
			breakTimeSecondMeal: "",
			totalHours: "",
			issameScheduled: false,
			id: 1,
			isChecked: false,
			formattedWorkingHours: "",
			previousworkweekvalue: ""
		},
		{
			name: "Monday",
			startTime: "",
			endTime: "",
			dateDiffer: false,
			isFirstMeal: false,
			isSecondMeal: false,
			startTimeFirstMeal: "",
			breakTimeFirstMeal: "",
			startTimeSecondMeal: "",
			breakTimeSecondMeal: "",
			totalHours: "",
			issameScheduled: false,
			id: 2,
			isChecked: true,
			formattedWorkingHours: "",
			previousworkweekvalue: ""
		},
		{
			name: "Tuesday",
			startTime: "",
			endTime: "",
			dateDiffer: false,
			isFirstMeal: false,
			isSecondMeal: false,
			startTimeFirstMeal: "",
			breakTimeFirstMeal: "",
			startTimeSecondMeal: "",
			breakTimeSecondMeal: "",
			totalHours: "",
			issameScheduled: false,
			id: 3,
			isChecked: true,
			formattedWorkingHours: "",
			previousworkweekvalue: ""
		},
		{
			name: "Wednesday",
			startTime: "",
			endTime: "",
			dateDiffer: false,
			isFirstMeal: false,
			isSecondMeal: false,
			startTimeFirstMeal: "",
			breakTimeFirstMeal: "",
			startTimeSecondMeal: "",
			breakTimeSecondMeal: "",
			totalHours: "",
			issameScheduled: false,
			id: 4,
			isChecked: true,
			formattedWorkingHours: "",
			previousworkweekvalue: ""
		},
		{
			name: "Thursday",
			startTime: "",
			endTime: "",
			dateDiffer: false,
			isFirstMeal: false,
			isSecondMeal: false,
			startTimeFirstMeal: "",
			breakTimeFirstMeal: "",
			startTimeSecondMeal: "",
			breakTimeSecondMeal: "",
			totalHours: "",
			issameScheduled: false,
			id: 5,
			isChecked: true,
			formattedWorkingHours: "",
			previousworkweekvalue: ""
		},
		{
			name: "Friday",
			startTime: "",
			endTime: "",
			dateDiffer: false,
			isFirstMeal: false,
			isSecondMeal: false,
			startTimeFirstMeal: "",
			breakTimeFirstMeal: "",
			startTimeSecondMeal: "",
			breakTimeSecondMeal: "",
			totalHours: "",
			issameScheduled: false,
			id: 6,
			isChecked: true,
			formattedWorkingHours: "",
			previousworkweekvalue: ""
		},
		{
			name: "Saturday",
			startTime: "",
			endTime: "",
			dateDiffer: false,
			isFirstMeal: false,
			isSecondMeal: false,
			startTimeFirstMeal: "",
			breakTimeFirstMeal: "",
			startTimeSecondMeal: "",
			breakTimeSecondMeal: "",
			totalHours: "",
			issameScheduled: false,
			id: 7,
			isChecked: true,
			formattedWorkingHours: "",
			previousworkweekvalue: ""
		}
	]

	//Get input from abother component in week_No and remove elements from weekdays array.
	connectedCallback() {
		this.isRecursive = true;
		if (this.workweekvalue > 0) {
			this.week_No = this.workweekvalue
			this.isrenderedCallback = true;
		} else {
			this.isrenderedCallback = false;
		}

		  switch(FORM_FACTOR) {
            case 'Large':
                this.isLargeDevice = true;
                break;
            case 'Medium':
                this.isMediumDevice = true;
                break;
            case 'Small':
                this.isSmallDevice = true;
                break;
        }
	}

	@api isrenderedCallback = false;


	renderedCallback() {
		if (this.week_No != null && this.isrenderedCallback === true && this.isRecursive === true) {
			const filteredEntriesBeforeSelectedWeek = this.timeEntriesDetails.filter(value => value.id >= this.week_No);
			const filteredEntriesAfterSelectedWeek = this.timeEntriesDetails.filter(value => value.id < this.week_No);
			const index = this.timeEntriesDetails.findIndex(value => value.id === this.week_No);
			this.timeEntryDetailDayBeforeSelectedDay.push(this.timeEntriesDetails[index - 1]);


			if (this.week_No == 8) {
				this.timeEntriesDetails.splice(0, 6);
			} else {
				this.timeEntriesDetails.splice(0, index);
			}


			for (var i = 0; i < filteredEntriesAfterSelectedWeek.length - 1; i++) {
				if(filteredEntriesAfterSelectedWeek[i] !== null && filteredEntriesAfterSelectedWeek[i] !== undefined){
					this.timeEntriesDetails.push(filteredEntriesAfterSelectedWeek[i]);
				}
			}

			//Add the missing day 
			if(this.timeEntryDetailDayBeforeSelectedDay[0] !== undefined && this.timeEntryDetailDayBeforeSelectedDay[0]!== null && this.timeEntryDetailDayBeforeSelectedDay.length > 0){
				this.timeEntriesDetails.push(this.timeEntryDetailDayBeforeSelectedDay[0]);
			}

			// change the values of isChecked 
			for (var j = 0; j < this.timeEntriesDetails.length; j++) {
				if(this.timeEntriesDetails[j] !== undefined && this.timeEntriesDetails[j] !== null){
					if(this.timeEntriesDetails[j].isChecked !== undefined && this.timeEntriesDetails[j].isChecked !== null){
						j === 0 ? this.timeEntriesDetails[j].isChecked = false : this.timeEntriesDetails[j].isChecked = true;
					}
				}
			}
			// const removeElement = this.timeEntriesDetails[index];
			// this.timeEntriesDetails.splice(index, 1);
			// this.timeEntriesDetails.push(removeElement);
		}
		if (this.isrenderedtimecalendar === true && this.timeentrydetail !== undefined) {
			
			this.isrenderedCallback = false;
			console.log('json');
			console.log(JSON.parse(JSON.stringify(this.timeentrydetail)));
			console.log(this.timeentrydetail);
			if ((this.timeentrydetail[0].previousworkweekvalue === undefined && this.week_No === null) || (this.timeentrydetail[0].previousworkweekvalue === '' && this.week_No === undefined) || (this.timeentrydetail[0].previousworkweekvalue === this.week_No)) {

				//if(this.timeEntriesDetails!= this.timeentrydetail){
						this.timeEntriesDetails = this.timeentrydetail;
				//}
				
				// this.isSameScheduled = this.timeEntriesDetails[0].sameSchedule;
			}
			if(this.isformpreviewmode == true){
					this.timeEntriesDetails = this.timeentrydetail;
			}
			this.isrenderedtimecalendar = false;
		}
		// this.timeEntriesDetails !== undefined ? this.timeEntriesDetails.filter(x=>x !== null) : ''
		this.isrenderedCallback = false;
	}


	_getSameSchedule = event => {
		this.sameSchedule = event.target.checked;

		if (this.sameSchedule) {
			this._repeatTimeEntries(event.target.value);
		} else {

			this._removeTimeEntries(event.target.value);
		}

		if (this.sameSchedule) {
				this.timeEntriesDetails.forEach(entry => {
					if (entry.id == event.target.value) {
						entry.issameScheduled = true;

					}
				});
		}else{
			this.timeEntriesDetails.forEach(entry => {
					if (entry.id == event.target.value) {
						entry.issameScheduled = false;
					}
				});
		}
	}

	_repeatTimeEntries = id => {

		//To set the values after previous and continue button clicks
		//this.timeEntriesDetails = JSON.parse(JSON.stringify(this.timeEntriesDetails));
		
		this.timeEntriesDetails = JSON.parse(JSON.stringify(this.timeEntriesDetails));

		const index = this.timeEntriesDetails.findIndex(value => value.id === Number(id));

		const firstDay = this.timeEntriesDetails[index-1];
		this.timeEntriesDetails[index].startTime = firstDay.startTime;
		this.timeEntriesDetails[index].endTime = firstDay.endTime;
		this.timeEntriesDetails[index].totalHours = firstDay.totalHours;
		this.timeEntriesDetails[index].isSecondMeal = firstDay.isSecondMeal;
		this.timeEntriesDetails[index].isFirstMeal = firstDay.isFirstMeal;
		this.timeEntriesDetails[index].startTimeFirstMeal = firstDay.startTimeFirstMeal;
		this.timeEntriesDetails[index].breakTimeFirstMeal = firstDay.breakTimeFirstMeal;
		this.timeEntriesDetails[index].startTimeSecondMeal = firstDay.startTimeSecondMeal;
		this.timeEntriesDetails[index].breakTimeSecondMeal = firstDay.breakTimeSecondMeal;
		this.timeEntriesDetails[index].dateDiffer = firstDay.dateDiffer;


	}

	_removeTimeEntries = id => {
		this.timeEntriesDetails = JSON.parse(JSON.stringify(this.timeEntriesDetails));
		const firstDay = this.timeEntriesDetails[0];
		const index = this.timeEntriesDetails.findIndex(value => value.id === Number(id));
		let sundayStartTime = firstDay.startTime;
		let sundayEndTime = firstDay.endTime;
		let sundayDiffHours = firstDay.totalHours;
		let sundayFirstMealStartTime = firstDay.startTimeFirstMeal;
		let sundayFirstMealBreakMin = firstDay.breakTimeFirstMeal;
		let sundaySecMealStartTime = firstDay.startTimeSecondMeal;
		let sundaySecMealBreakTime = firstDay.breakTimeSecondMeal;
		let sundayDateDiffer = firstDay.dateDiffer;

		this.timeEntriesDetails[index].startTime = '';
		this.timeEntriesDetails[index].endTime = '';
		this.timeEntriesDetails[index].totalHours = '';
		this.timeEntriesDetails[index].isSecondMeal = false;
		this.timeEntriesDetails[index].isFirstMeal = false;
		this.timeEntriesDetails[index].startTimeFirstMeal = '';
		this.timeEntriesDetails[index].breakTimeFirstMeal = '';
		this.timeEntriesDetails[index].startTimeSecondMeal = '';
		this.timeEntriesDetails[index].breakTimeSecondMeal = '';
		this.timeEntriesDetails[index].dateDiffer = false;

		this.timeEntriesDetails[0].startTime = sundayStartTime;
		this.timeEntriesDetails[0].endTime = sundayEndTime;
		this.timeEntriesDetails[0].totalHours = sundayDiffHours;
		this.timeEntriesDetails[0].totalHours = sundayDiffHours;
		this.timeEntriesDetails[0].startTimeFirstMeal = sundayFirstMealStartTime;
		this.timeEntriesDetails[0].breakTimeFirstMeal = sundayFirstMealBreakMin;
		this.timeEntriesDetails[0].startTimeSecondMeal = sundaySecMealStartTime;
		this.timeEntriesDetails[0].breakTimeSecondMeal = sundaySecMealBreakTime;
		this.timeEntriesDetails[0].dateDiffer = sundayDateDiffer;

	}


	handleChange = event => {

		let day = event.currentTarget.dataset.day;
		let name = event.target.name;
		let time = event.target.value;
		let DiffMin;
		//To set the values after previous and continue button clicks
		// array.filter(x => x !== null)
		this.timeEntriesDetails = JSON.parse(JSON.stringify(this.timeEntriesDetails));


		this.timeEntriesDetails.forEach(entry => {
			if(entry !== null){
				if (day.toLowerCase() == entry.name.toLowerCase()) {

					if (name == 'datediffer') {
						entry.dateDiffer = event.target.checked;
					} else {
						entry[name] = time.trim();
					}
					if (entry.endTime == undefined || entry.endTime == '') {
						entry.totalHours = 0;
					} else if (entry.endTime != undefined && entry.startTime != undefined) {
	
						let hours;
	
						if (parseInt(entry.endTime.split(":")[0]) < parseInt(entry.startTime.split(":")[0])) {
							hours = 24 + parseInt(entry.endTime.split(":")[0]) - parseInt(entry.startTime.split(":")[0]);
						} else if (parseInt(entry.endTime.split(":")[0]) == parseInt(entry.startTime.split(":")[0]) && parseInt(entry.endTime.split(":")[1]) < parseInt(entry.startTime.split(":")[1])) {
							hours = 24 + parseInt(entry.endTime.split(":")[0]) - parseInt(entry.startTime.split(":")[0]);
						} else {
							hours = parseInt(entry.endTime.split(":")[0]) - parseInt(entry.startTime.split(":")[0]);
						}
	
						if (entry.startTime.split(":")[1] != '00' && entry.endTime.split(":")[1] == '00') {
							
							let hrsInSec;
							let hr;
							let min;
							let minInSec;
							let totalSec;
							//Code to set TotalWorkHours on basis of firstmeal and secondmeal time
	
							DiffMin = 60 - (parseInt(entry.startTime.split(":")[1]));
	
	
							if (entry.breakTimeFirstMeal != '' && entry.breakTimeSecondMeal == '') {
	
								hrsInSec = hours * 3600;
								minInSec = DiffMin * 60;
								totalSec = (hrsInSec + minInSec) - (entry.breakTimeFirstMeal * 60);

								hr = Math.floor(totalSec / 3600);
								min = Math.floor(totalSec % 3600 / 60);
	
								entry.totalHours = hr - 1 + "hr" + " " + min + "min";
								//Store hr and min in form of 1.15
								entry.formattedWorkingHours = hr - 1 + "." + min;
							} else if (entry.breakTimeSecondMeal != '' && entry.breakTimeFirstMeal == '') {
	
								hrsInSec = hours * 3600;
								minInSec = DiffMin * 60;
								totalSec = (hrsInSec + minInSec) - (entry.breakTimeSecondMeal * 60);
	
								hr = Math.floor(totalSec / 3600);
								min = Math.floor(totalSec % 3600 / 60);
	
								entry.totalHours = hr - 1 + "hr" + " " + min + "min";
								//Store hr and min in form of 1.15
								entry.formattedWorkingHours = hr - 1 + "." + min;
	
							} else if (entry.breakTimeFirstMeal != '' && entry.breakTimeSecondMeal != '') {
								hrsInSec = hours * 3600;
								minInSec = DiffMin * 60;
								totalSec = (hrsInSec + minInSec) - (entry.breakTimeFirstMeal * 60);
								totalSec = totalSec - (entry.breakTimeSecondMeal * 60);
	
								hr = Math.floor(totalSec / 3600);
								min = Math.floor(totalSec % 3600 / 60);
								entry.totalHours = hr - 1 + "hr" + " " + min + "min";
								//Store hr and min in form of 1.15
								entry.formattedWorkingHours = hr - 1 + "." + min;
	
							} else {
								entry.totalHours = hours - 1 + "hr" + " " + DiffMin + "min";
								//Store hr and min in form of 1.15
								entry.formattedWorkingHours = hours - 1 + "." + DiffMin;
							}
	
						} else if (entry.startTime.split(":")[1] != '00' && entry.endTime.split(":")[1] != '00') {
							let DiffMin;
	
							if (parseInt(entry.startTime.split(":")[1]) > parseInt(entry.endTime.split(":")[1])) {
								hours = hours - 1;
								DiffMin = 60 - (parseInt(entry.startTime.split(":")[1]));
								DiffMin = DiffMin + (parseInt(entry.endTime.split(":")[1]));
	
	
								let hrsInSec;
								let hr;
								let min;
								let minInSec;
								let totalSec;
	
	
								if (entry.breakTimeFirstMeal != '' && entry.breakTimeSecondMeal == '') {
	
									hrsInSec = hours * 3600;
									minInSec = DiffMin * 60;
									totalSec = (hrsInSec + minInSec) - (entry.breakTimeFirstMeal * 60);
	
									hr = Math.floor(totalSec / 3600);
									min = Math.floor(totalSec % 3600 / 60);
	
									entry.totalHours = hr + "hr" + " " + min + "min";
									//Store hr and min in form of 1.15
									entry.formattedWorkingHours = hr + "." + min;
									//Store hr and min in form of 1.15
								} else if (entry.breakTimeSecondMeal != '' && entry.breakTimeFirstMeal == '') {
	
									hrsInSec = hours * 3600;
									minInSec = DiffMin * 60;
									totalSec = (hrsInSec + minInSec) - (entry.breakTimeSecondMeal * 60);
	
									hr = Math.floor(totalSec / 3600);
									min = Math.floor(totalSec % 3600 / 60);
	
									entry.totalHours = hr + "hr" + " " + min + "min";
									//Store hr and min in form of 1.15
									entry.formattedWorkingHours = hr + "." + min;
	
								} else if (entry.breakTimeFirstMeal != '' && entry.breakTimeSecondMeal != '') {
									hrsInSec = entry.dateDiffer ? (hours + 23) * 3600 : hours * 3600;
									minInSec = DiffMin * 60;
									totalSec = (hrsInSec + minInSec) - (entry.breakTimeFirstMeal * 60);
									totalSec = totalSec - (entry.breakTimeSecondMeal * 60);
	
									hr = Math.floor(totalSec / 3600);
									min = Math.floor(totalSec % 3600 / 60);
									entry.totalHours = hr + "hr" + " " + min + "min";
									//Store hr and min in form of 1.15
									entry.formattedWorkingHours = hr + "." + min;
	
								} else {
									entry.totalHours = hours + "hr" + " " + DiffMin + "min";
									//Store hr and min in form of 1.15
									entry.formattedWorkingHours = hours + "." + DiffMin;
								}
	
	
							} else if (parseInt(entry.startTime.split(":")[1]) < parseInt(entry.endTime.split(":")[1])) {
	
								DiffMin = (parseInt(entry.endTime.split(":")[1])) - parseInt(entry.startTime.split(":")[1]);
	
								let hrsInSec;
								let hr;
								let min;
								let minInSec;
								let totalSec;
	
	
								if (entry.breakTimeFirstMeal != '' && entry.breakTimeSecondMeal == '') {
	
									hrsInSec = hours * 3600;
									minInSec = DiffMin * 60;
									totalSec = (hrsInSec + minInSec) - (entry.breakTimeFirstMeal * 60);
	
									hr = Math.floor(totalSec / 3600);
									min = Math.floor(totalSec % 3600 / 60);
	
									entry.totalHours = hr + "hr" + " " + min + "min";
									//Store hr and min in form of 1.15
									entry.formattedWorkingHours = hr + "." + min;
	
								} else if (entry.breakTimeSecondMeal != '' && entry.breakTimeFirstMeal == '') {
	
									hrsInSec = hours * 3600;
									minInSec = DiffMin * 60;
									totalSec = (hrsInSec + minInSec) - (entry.breakTimeSecondMeal * 60);
	
									hr = Math.floor(totalSec / 3600);
									min = Math.floor(totalSec % 3600 / 60);
	
									entry.totalHours = hr + "hr" + " " + min + "min";
									//Store hr and min in form of 1.15
									entry.formattedWorkingHours = hr + "." + min;
	
								} else if (entry.breakTimeFirstMeal != '' && entry.breakTimeSecondMeal != '') {
									hrsInSec = hours * 3600;
									minInSec = DiffMin * 60;
									totalSec = (hrsInSec + minInSec) - (entry.breakTimeFirstMeal * 60);
									totalSec = totalSec - (entry.breakTimeSecondMeal * 60);
	
									hr = Math.floor(totalSec / 3600);
									min = Math.floor(totalSec % 3600 / 60);
									entry.totalHours = hr + "hr" + " " + min + "min";
									//Store hr and min in form of 1.15
									entry.formattedWorkingHours = hr + "." + min;
	
								} else {
									entry.totalHours = hours + "hr" + " " + DiffMin + "min";
									//Store hr and min in form of 1.15
									entry.formattedWorkingHours = hours + "." + DiffMin;
								}
	
							} else if (parseInt(entry.startTime.split(":")[1]) == parseInt(entry.endTime.split(":")[1])) {
								DiffMin = 0;
	
								let hrsInSec;
								let hr;
								let min;
								let minInSec;
								let totalSec;
	
	
								if (entry.breakTimeFirstMeal != '' && entry.breakTimeSecondMeal == '') {
	
									hrsInSec = hours * 3600;
									minInSec = DiffMin * 60;
									totalSec = (hrsInSec + minInSec) - (entry.breakTimeFirstMeal * 60);
	
									hr = Math.floor(totalSec / 3600);
									min = Math.floor(totalSec % 3600 / 60);
	
									entry.totalHours = hr + "hr" + " " + min + "min";
									//Store hr and min in form of 1.15
									entry.formattedWorkingHours = hr + "." + min;
									//Store hr and min in form of 1.15
									
								} else if (entry.breakTimeSecondMeal != '' && entry.breakTimeFirstMeal == '') {
	
									hrsInSec = hours * 3600;
									minInSec = DiffMin * 60;
									totalSec = (hrsInSec + minInSec) - (entry.breakTimeSecondMeal * 60);
	
									hr = Math.floor(totalSec / 3600);
									min = Math.floor(totalSec % 3600 / 60);
	
									entry.totalHours = hr + "hr" + " " + min + "min";
									//Store hr and min in form of 1.15
									entry.formattedWorkingHours = hr + "." + min;
	
								} else if (entry.breakTimeFirstMeal != '' && entry.breakTimeSecondMeal != '') {
									hrsInSec = hours * 3600;
									minInSec = DiffMin * 60;
									totalSec = (hrsInSec + minInSec) - (entry.breakTimeFirstMeal * 60);
									totalSec = totalSec - (entry.breakTimeSecondMeal * 60);
	
									hr = Math.floor(totalSec / 3600);
									min = Math.floor(totalSec % 3600 / 60);
									entry.totalHours = hr + "hr" + " " + min + "min";
									//Store hr and min in form of 1.15
									entry.formattedWorkingHours = hr + "." + min;
	
								} else {
									entry.totalHours = hours + "hr" + " " + DiffMin + "min";
									//Store hr and min in form of 1.15
									entry.formattedWorkingHours = hours + "." + DiffMin;
								}
	
							} else {
								entry.totalHours = hours + "hr" + " " + DiffMin + "min";
								//Store hr and min in form of 1.15
								entry.formattedWorkingHours = hours + "." + DiffMin;
							}
	
						} else if (entry.endTime.split(":")[1] != '00' && entry.startTime.split(":")[1] == '00') {
							DiffMin = entry.endTime.split(":")[1];
	
							let hrsInSec;
							let hr;
							let min;
							let minInSec;
							let totalSec;
	
							if (entry.breakTimeFirstMeal != '' && entry.breakTimeSecondMeal == '') {
	
								hrsInSec = hours * 3600;
								minInSec = DiffMin * 60;
								totalSec = (hrsInSec + minInSec) - (entry.breakTimeFirstMeal * 60);
	
								hr = Math.floor(totalSec / 3600);
								min = Math.floor(totalSec % 3600 / 60);
	
								entry.totalHours = hr + "hr" + " " + min + "min";
								entry.formattedWorkingHours = hr + "." + min;
							} else if (entry.breakTimeSecondMeal != '' && entry.breakTimeFirstMeal == '') {
	
								hrsInSec = hours * 3600;
								minInSec = DiffMin * 60;
								totalSec = (hrsInSec + minInSec) - (entry.breakTimeSecondMeal * 60);
	
								hr = Math.floor(totalSec / 3600);
								min = Math.floor(totalSec % 3600 / 60);
	
								entry.totalHours = hr + "hr" + " " + min + "min";
								entry.formattedWorkingHours = hr + "." + min;
	
							} else if (entry.breakTimeFirstMeal != '' && entry.breakTimeSecondMeal != '') {
								hrsInSec = hours * 3600;
								minInSec = DiffMin * 60;
								totalSec = (hrsInSec + minInSec) - (entry.breakTimeFirstMeal * 60);
								totalSec = totalSec - (entry.breakTimeSecondMeal * 60);
	
								hr = Math.floor(totalSec / 3600);
								min = Math.floor(totalSec % 3600 / 60);
	
								entry.totalHours = hr + "hr" + " " + min + "min";
								entry.formattedWorkingHours = hr + "." + min;
	
							} else {
								entry.totalHours = hours + "hr" + " " + DiffMin + "min";
								entry.formattedWorkingHours = hours + "." + DiffMin;
							}
	
						} else {
	
							DiffMin = 0;
							let hrsInSec;
							let hr;
							let min;
							let minInSec;
							let totalSec;
	
	
							if (entry.breakTimeFirstMeal != '' && entry.breakTimeSecondMeal == '') {
	
								hrsInSec = hours * 3600;
								minInSec = DiffMin * 60;
								totalSec = (hrsInSec + minInSec) - (entry.breakTimeFirstMeal * 60);
	
								hr = Math.floor(totalSec / 3600);
								min = Math.floor(totalSec % 3600 / 60);
	
								entry.totalHours = hr + "hr" + " " + min + "min";
	
								entry.formattedWorkingHours = hr;
							} else if (entry.breakTimeSecondMeal != '' && entry.breakTimeFirstMeal == '') {
	
								hrsInSec = hours * 3600;
								minInSec = DiffMin * 60;
								totalSec = (hrsInSec + minInSec) - (entry.breakTimeSecondMeal * 60);
	
								hr = Math.floor(totalSec / 3600);
								min = Math.floor(totalSec % 3600 / 60);
	
								entry.totalHours = hr + "hr" + " " + min + "min";
								entry.formattedWorkingHours = hr;
	
							} else if (entry.breakTimeFirstMeal != '' && entry.breakTimeSecondMeal != '') {
								hrsInSec = hours * 3600;
								minInSec = DiffMin * 60;
								totalSec = (hrsInSec + minInSec) - (entry.breakTimeFirstMeal * 60);
								totalSec = totalSec - (entry.breakTimeSecondMeal * 60);
	
								hr = Math.floor(totalSec / 3600);
								min = Math.floor(totalSec % 3600 / 60);
	
	
								entry.totalHours = hr + "hr" + " " + min + "min";
								entry.formattedWorkingHours = hr;
	
							} else {
								entry.totalHours = hours + "hr" + " " + DiffMin + "min";
	
								entry.formattedWorkingHours = hours;
							}
						}
	
						if (entry.totalHours.split("hr")[0] < 10) {
							entry.isFirstMeal = true;
							if (entry.breakTimeSecondMeal == '' || entry.breakTimeSecondMeal == undefined || entry.breakTimeSecondMeal == null) {
								entry.isSecondMeal = false;
							}
						}
						if (entry.totalHours.split("hr")[0] >= 10) {
							entry.isSecondMeal = true;
							entry.isFirstMeal = true;
						}
						if (entry.totalHours.split("hr")[0] < 5) {
							if (entry.breakTimeSecondMeal == '' || entry.breakTimeSecondMeal == undefined || entry.breakTimeSecondMeal == null) {
								entry.isSecondMeal = false;
							}
							if (entry.breakTimeFirstMeal == '' || entry.breakTimeFirstMeal == undefined || entry.breakTimeFirstMeal == null) {
								entry.isFirstMeal = false;
							}
						}
						entry.sameSchedule = this.sameSchedule;
						console.log('fffsfs');
						console.log(this.week_No);
						console.log(this.workweekvalue);
						
						this.timeEntriesDetails[0].previousworkweekvalue = this.week_No;

						console.log(JSON.parse(JSON.stringify(this.timeEntriesDetails)));
						
					}
				}
			}
		});
	}

	@api isHelpText = false;
	@api helpText;
	// Handle Help text
	handleHelpText(event) {
		const learnMoreName = event.target.name;
		if(learnMoreName === 'breakTimeHelpText'){
			this.isHelpText = true;
			this.helpText = this.customLabelValues.OWC_break_length_helptext
		}
		else if (learnMoreName === 'timeHelpText') {
			this.isHelpText = true;
			this.helpText = this.customLabelValues.OWC_calendar_time_helptext
		}

	}

	// Handle Help text Event
	handleHelpTextEvent(event) {
		const helpTextValue = event.detail;
		this.isHelpText = helpTextValue.isClosedHelpText
	}

}