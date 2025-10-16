import plotly.graph_objects as go

# Parse the provided data with exact colors from JSON
data = {
    "timeline": {
        "phases": [
            {"name": "Phase 1: Foundation", "duration": 3, "color": "#4CAF50", "tasks": ["Project Setup & Architecture", "Core Audio Engine Development", "Basic ML Model Training", "iOS/iPad UI Framework"]},
            {"name": "Phase 2: Core Features", "duration": 3, "color": "#2196F3", "tasks": ["Snore Detection Algorithm", "Real-time Audio Processing", "HealthKit Integration", "Cloud Data Synchronization"]},
            {"name": "Phase 3: Advanced Features", "duration": 3, "color": "#FF9800", "tasks": ["Advanced Analytics Engine", "StandBy Mode Widgets", "iPad Always-On Display", "Performance Optimization"]},
            {"name": "Phase 4: Polish & Launch", "duration": 3, "color": "#9C27B0", "tasks": ["UI/UX Refinement", "Beta Testing & Feedback", "App Store Submission", "Launch & Marketing"]}
        ],
        "milestones": [
            {"name": "MVP Complete", "month": 6},
            {"name": "Beta Release", "month": 9},
            {"name": "App Store Approval", "month": 11},
            {"name": "Public Launch", "month": 12}
        ]
    }
}

# Better task abbreviations that are more accurate to originals (under 15 chars)
task_abbreviations = {
    "Project Setup & Architecture": "Project Setup",
    "Core Audio Engine Development": "Audio Engine",
    "Basic ML Model Training": "ML Model Train", 
    "iOS/iPad UI Framework": "UI Framework",
    "Snore Detection Algorithm": "Snore Algorithm",
    "Real-time Audio Processing": "Audio Process",
    "HealthKit Integration": "HealthKit Int",
    "Cloud Data Synchronization": "Cloud Data Sync",
    "Advanced Analytics Engine": "Analytics Eng",
    "StandBy Mode Widgets": "StandBy Widget",
    "iPad Always-On Display": "Always-On Disp",
    "Performance Optimization": "Performance",
    "UI/UX Refinement": "UI/UX Refine",
    "Beta Testing & Feedback": "Beta Testing",
    "App Store Submission": "App Store Sub",
    "Launch & Marketing": "Launch Market"
}

# Create the Gantt chart
fig = go.Figure()

# Track y positions and labels, organizing by phase
y_position = 0
y_labels = []

# Add tasks for each phase with proper grouping
for phase_idx, phase in enumerate(data["timeline"]["phases"]):
    # Phase starts: 1, 4, 7, 10 (months 1-3, 4-6, 7-9, 10-12)
    phase_start = phase_idx * 3 + 1
    phase_color = phase["color"]  # Use exact color from data
    phase_name = phase["name"]
    
    # Add tasks for this phase in order
    for task_idx, task in enumerate(phase["tasks"]):
        task_name = task_abbreviations.get(task, task[:15])
        y_labels.append(task_name)
        
        # Each task spans the full phase duration (3 months)
        fig.add_trace(go.Bar(
            x=[3],  # Duration of 3 months
            y=[y_position],
            base=[phase_start - 1],  # Start position (0-indexed for plotly)
            orientation='h',
            name=phase_name,
            marker_color=phase_color,
            showlegend=(task_idx == 0),  # Only show legend for first task of each phase
            hovertemplate=f'{task_name}<br>{phase_name}<br>Months {phase_start}-{phase_start + 2}<extra></extra>'
        ))
        y_position += 1
    
    # Add spacing between phases
    if phase_idx < len(data["timeline"]["phases"]) - 1:
        y_position += 0.8

# Add milestones with better positioning to avoid overlap
milestone_positions = [
    {"y_offset": 1.5, "text_pos": "top center"},
    {"y_offset": 2.2, "text_pos": "top center"}, 
    {"y_offset": 1.5, "text_pos": "top center"},
    {"y_offset": 2.2, "text_pos": "top center"}
]

milestone_y_base = y_position + 1
for milestone_idx, milestone in enumerate(data["timeline"]["milestones"]):
    milestone_name = milestone["name"]
    if len(milestone_name) > 15:
        # Abbreviate milestone names if needed
        milestone_abbrev = {
            "App Store Approval": "App Store Appr",
            "Public Launch": "Public Launch"
        }
        milestone_name = milestone_abbrev.get(milestone_name, milestone_name[:15])
    
    pos_info = milestone_positions[milestone_idx]
    milestone_y = milestone_y_base + pos_info["y_offset"]
    
    fig.add_trace(go.Scatter(
        x=[milestone["month"]],
        y=[milestone_y],
        mode='markers+text',
        marker=dict(
            size=12,
            color='#DB4545',
            symbol='diamond',
            line=dict(width=2, color='white')
        ),
        text=[milestone_name],
        textposition=pos_info["text_pos"],
        name='Milestones',
        showlegend=(milestone_idx == 0),
        hovertemplate=f'{milestone_name}<br>Month {milestone["month"]}<extra></extra>'
    ))

# Update layout with better spacing
fig.update_layout(
    title="iOS Snore Detection App Timeline",
    xaxis_title="Month",
    yaxis=dict(
        tickmode='array',
        tickvals=list(range(len(y_labels))),
        ticktext=y_labels,
        autorange='reversed'
    ),
    xaxis=dict(
        range=[0, 13],
        dtick=1,
        tickmode='linear',
        tick0=1
    ),
    barmode='overlay',
    legend=dict(
        orientation='h',
        yanchor='bottom',
        y=1.05,
        xanchor='center',
        x=0.5
    )
)

# Update traces for better appearance
fig.update_traces(cliponaxis=False)

# Save as both PNG and SVG
fig.write_image("gantt_chart.png")
fig.write_image("gantt_chart.svg", format="svg")

fig.show()